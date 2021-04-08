//
//  CanvasView.swift
//  
//
//  Created by Raheel Ahmad on 3/29/21.
//

import SwiftUI
import Combine

import NodeView

struct TextUpdate {
    let text: String?
    let nodeId: String
}

public final class CanvasUIView: UIView {
    var currentLine: Line? = nil {
        didSet {
            setNeedsDisplay()
        }
    }

    private(set) var nodeViews: [NodeUIView] = [] {
        didSet {
            for view in nodeViews {
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

    let textUpdated = PassthroughSubject<TextUpdate, Never>()

    lazy var nodeRecognizer = NodeRecognizer(target: self, action: #selector(nodeRecognition(recognizer:)))
    lazy var linkRecognizer = LinkRecognizer(target: self, action: #selector(linkRecognition(recognizer:)))

    private var cancellables: [AnyCancellable] = []

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
            setNeedsDisplay()
        }
    }

    @objc
    private func nodeRecognition(recognizer: NodeRecognizer) {
        switch recognizer.state {
        case .recognized:
            if let rect = recognizer.line?.boundingRect {
                nodeRecognized.send(NodeRecognition(center: CGPoint(x: rect.midX, y: rect.midY)))
            }
        default:
            setNeedsDisplay()
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        for link in links {
            guard
                let from = nodeViews.first(where: { $0.id == link.fromId }),
                let to = nodeViews.first(where: { $0.id == link.toId })
            else {
                assertionFailure("Could not find nodes for links")
                continue
            }

            link.updateLinkPath(from: from, to: to)
        }
    }
}

extension CanvasUIView {
    func update(_ updatedNodes: [Node]) {
        let existingNodeIds = nodeViews.map { $0.id }
        let new = updatedNodes.filter { !existingNodeIds.contains($0.id) }
        for newNode in new {
            addNode(for: newNode)
        }

        // LATER: modified: update centers when we implement move
        // LATER: deleted: after we implement delete

        for node in updatedNodes {
            for linkedNodeId in node.linkedNodeIds {
                guard
                    let from = nodeViews.first(where: { $0.id == node.id }),
                    let to = nodeViews.first(where: { $0.id == linkedNodeId })
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

                linkLayer.updateLinkPath(from: from, to: to)
            }
        }

        setNeedsDisplay()
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

        let color = UInt(node.colorHex, radix: 16).map { UIColor.hex($0) }

        view.updateText(node.title)
        view.updateColor(color)

        let dragger = UIDragInteraction(delegate: self)
        view.addInteraction(dragger)

        view.textUpdated.sink { [weak self] text in
            self?.textUpdated.send(TextUpdate(text: text, nodeId: node.id))
        }.store(in: &cancellables)

        addSubview(view)
        self.nodeViews.append(view)
        // LATER: only activate if a new node, and not just adding initial nodes
//        DispatchQueue.main.async {
//            view.activateEditing()
//        }
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
        let color = UIColor.hex(0xEDE0E0)
        context?.setFillColor(color.cgColor)
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
    }
}
