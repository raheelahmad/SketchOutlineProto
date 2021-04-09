//
//  CanvasView.swift
//  
//
//  Created by Raheel Ahmad on 3/29/21.
//

import SwiftUI
import Combine

import NodeView

struct NodeUpdate {
    enum Kind {
        case text(String?)
        case position(Position)
    }

    let kind: Kind
    let id: String
}

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

    let textUpdated = PassthroughSubject<NodeUpdate, Never>()

    var currentDraggedNodeOffsetFromCenter: CGPoint?

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
        let dropInteraction = UIDropInteraction(delegate: self)
        addInteraction(dropInteraction)

        view.textUpdated.sink { [weak self] text in
            self?.textUpdated.send(NodeUpdate(kind: .text(text), id: node.id))
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

extension CanvasUIView: UIDragInteractionDelegate, UIDropInteractionDelegate {
    public func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let nodeView = interaction.view as? NodeUIView else {
            return []
        }

        let locationInNode = session.location(in: nodeView)
        let offset = CGPoint(x: locationInNode.x - nodeView.bounds.midX, y: locationInNode.y - nodeView.bounds.midY)
        self.currentDraggedNodeOffsetFromCenter = offset

        let provider = NSItemProvider(item: nodeView.id as NSString, typeIdentifier: "node")
        return [UIDragItem(itemProvider: provider)]
    }

    public func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        guard let nodeView = interaction.view as? NodeUIView else {
            return nil
        }
        return UITargetedDragPreview(view: nodeView, parameters: UIPreviewParameters())
    }

    public func dragInteraction(_ interaction: UIDragInteraction, sessionDidMove session: UIDragSession) {
        guard let nodeView = interaction.view as? NodeUIView else {
            return
        }

        var loc = session.location(in: self)
        if let offset = currentDraggedNodeOffsetFromCenter {
            loc.x -= offset.x
            loc.y -= offset.y
        }
        let pos = Position(x: Double(loc.x/bounds.width), y: Double(loc.y/bounds.height))
        textUpdated.send(NodeUpdate(kind: .position(pos), id: nodeView.id))
        nodeView.center = loc
    }

    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
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
