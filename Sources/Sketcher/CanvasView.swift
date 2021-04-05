//
//  CanvasView.swift
//  
//
//  Created by Raheel Ahmad on 3/29/21.
//

import SwiftUI
import Combine

import NodeView

final class LinkUIView: UIView {
    let from: NodeUIView
    let to: NodeUIView
    private(set) var path: UIBezierPath

    init(from: NodeUIView, to: NodeUIView) {
        self.from = from
        self.to = to
        self.path = Self.path(from: from, to: to)

        super.init(frame: .zero)
    }

    func updatePath() {
        self.path = Self.path(from: from, to: to)
    }

    private static func path(from: UIView, to: UIView) -> UIBezierPath {
        let p = UIBezierPath()
        p.move(to: from.center)
        p.addLine(to: to.center)
        return p
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class LinkLayer: CAShapeLayer {
    let fromId: String
    let toId: String

    init(fromId: String, toId: String) {
        self.fromId = fromId
        self.toId = toId

        super.init()

        self.strokeColor = UIColor.red.cgColor
        self.lineWidth = 6
        self.fillColor = UIColor.clear.cgColor
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

struct NodeRecognition {
    let center: CGPoint
}

enum LinkRecognition {
    case onlyFrom(fromNodeId: String, to: CGPoint)
    case fromTo(fromNodeId: String, toNodeId: String)
}

public final class CanvasUIView: UIView {
    var currentLine: Line? = nil {
        didSet {
            setNeedsDisplay()
        }
    }

    private(set) var nodes: [NodeUIView] = [] {
        didSet {
            for view in nodes {
                addSubview(view)
            }
        }
    }

    private var links: [LinkLayer] = [] {
        didSet {
            for layer in links {
                // Make sure all link layers are below all subviews (the node views)
                self.layer.insertSublayer(layer, at: 0)
            }
        }
    }

    let nodeRecognized = PassthroughSubject<NodeRecognition, Never>()
    let linkRecognized = PassthroughSubject<LinkRecognition, Never>()

    lazy var nodeRecognizer = NodeRecognizer(target: self, action: #selector(nodeRecognition(recognizer:)))
    lazy var linkRecognizer = LinkRecognizer(target: self, action: #selector(linkRecognition(recognizer:)))

    init() {
        super.init(frame: .zero)

        addGestureRecognizer(nodeRecognizer)
        addGestureRecognizer(linkRecognizer)
    }

    @objc
    private func linkRecognition(recognizer: LinkRecognizer) {
        switch recognizer.state {
        case .recognized:
            guard let from = recognizer.initialSubview else {
                assertionFailure("No from view for a recognized link")
                return
            }
            guard let line = recognizer.line else {
                assertionFailure("No line for a recognized link")
                return
            }

            if let recognizedToView = recognizer.finalSubview {
                linkRecognized.send(.fromTo(fromNodeId: from.id, toNodeId: recognizedToView.id))
            } else {
                linkRecognized.send(.onlyFrom(fromNodeId: from.id, to: line.points.last!))
            }
        default:
            break
        }
        setNeedsDisplay()
    }

    @objc
    private func nodeRecognition(recognizer: NodeRecognizer) {
        switch recognizer.state {
        case .recognized:
            if let rect = recognizer.line?.boundingRect {
                nodeRecognized.send(NodeRecognition(center: CGPoint(x: rect.midX, y: rect.midY)))
            }
        default:
            break
        }
        setNeedsDisplay()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CanvasUIView {
    func update(_ updated: [Node]) {
        let existingNodeIds = nodes.map { $0.id }
        let new = updated.filter { !existingNodeIds.contains($0.id) }
        for newNode in new {
            addNode(for: newNode)
        }

        // TODO: modified: update centers
        // TODO: deleted:

        // TODO: links (update paths, remove, insert)
        for node in updated {
            for linkedNodeId in node.linkedNodeIds {
                guard
                    let from = nodes.first(where: { $0.id == node.id }),
                    let to = nodes.first(where: { $0.id == linkedNodeId })
                else {
                    assertionFailure("Could not find nodes to link to")
                    continue
                }

                let linkLayer: LinkLayer
                if let existing = links.first(where: { $0.fromId == node.id && $0.toId == linkedNodeId }) {
                    linkLayer = existing
                } else {
                    let newLinkLayer = LinkLayer(fromId: from.id, toId: to.id)
                    links.append(newLinkLayer)
                    linkLayer = newLinkLayer
                }

                updateLinkPath(from: from, to: to, layer: linkLayer)
            }
        }

        setNeedsDisplay()
    }

    private func updateLinkPath(from: NodeUIView, to: NodeUIView, layer: LinkLayer) {
        let p = UIBezierPath()
        p.move(to: from.center)
        let mid = from.center.midPoint(between: to.center)
        var mid1 = from.center.midPoint(between: mid)
        var mid2 = mid.midPoint(between: to.center)
        mid1.y -= 30
        mid2.y -= 30
        p.addCurve(to: to.center, controlPoint1: mid1, controlPoint2: mid2)
        layer.path = p.cgPath
    }
}

extension CanvasUIView {
    @discardableResult
    private func addNode(for node: Node) -> NodeUIView {
        let view = NodeUIView(id: node.id)
        view.center = .init(
            x: bounds.width * CGFloat(node.fractPos.x),
            y: bounds.height * CGFloat(node.fractPos.y)
        )
        let dragger = UIDragInteraction(delegate: self)
        view.addInteraction(dragger)
        addSubview(view)
        self.nodes.append(view)
        DispatchQueue.main.async {
            view.activateEditing()
        }
        return view
    }
}

extension CanvasUIView: UIDragInteractionDelegate {
    public func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension CanvasUIView {
    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(rect)

        // Draw any in-progress paths
        if let p = nodeRecognizer.line?.bezier() {
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.setLineWidth(5)

            context?.addPath(p.cgPath)
            context?.strokePath()
        } else if let p = linkRecognizer.line?.bezier() {
            context?.setStrokeColor(UIColor.yellow.cgColor)
            context?.setLineWidth(12)

            context?.addPath(p.cgPath)
            context?.strokePath()
        }

        // TODO: currently saving path in LinkUIView without drawing it there.
        // Should just use a CALayer
//        for link in self.links.map({ $0.path }) {
//            context?.setStrokeColor(UIColor.systemGray3.cgColor)
//            context?.setLineWidth(6)
//
//            context?.addPath(link.cgPath)
//            context?.strokePath()
//        }
    }
}
