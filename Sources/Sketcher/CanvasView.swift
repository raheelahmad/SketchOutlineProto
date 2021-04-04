//
//  CanvasView.swift
//  
//
//  Created by Raheel Ahmad on 3/29/21.
//

import SwiftUI

import NodeView

public struct CanvasView: UIViewRepresentable {
    public init() {}

    public func makeUIView(context: Context) -> some UIView {
        CanvasUIView()
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView()
    }
}

final class LinkUIView: UIView {
    let from: NodeUIView
    let to: NodeUIView
    let path: UIBezierPath

    init(from: NodeUIView, to: NodeUIView, path: UIBezierPath) {
        self.from = from
        self.to = to
        self.path = path

        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

final class CanvasUIView: UIView {
    var currentLine: Line? = nil {
        didSet {
            setNeedsDisplay()
        }
    }

    private var nodes: [NodeUIView] = [] {
        didSet {
            for view in nodes {
                addSubview(view)
            }
        }
    }

    private var links: [LinkUIView] = [] {
        didSet {
            for view in links {
                addSubview(view)
            }
        }
    }

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

            let to = recognizer.finalSubview ?? addNode(at: line.points.last!)
            let link = LinkUIView(from: from as! NodeUIView, to: to as! NodeUIView, path: line.bezier())
            self.links.append(link)
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
                addNode(at: CGPoint(x: rect.midX, y: rect.midY))
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
    @discardableResult
    private func addNode(at point: CGPoint) -> NodeUIView {
        let nodeView = NodeView.NodeUIView()
        let dragger = UIDragInteraction(delegate: self)
        nodeView.addInteraction(dragger)
        addSubview(nodeView)
        nodeView.center = point
        self.nodes.append(nodeView)
        DispatchQueue.main.async {
            nodeView.activateEditing()
        }
        return nodeView
    }
}

extension CanvasUIView: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension CanvasUIView {
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(rect)

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

        for link in self.links.map({ $0.path }) {
            context?.setStrokeColor(UIColor.systemGray3.cgColor)
            context?.setLineWidth(6)

            context?.addPath(link.cgPath)
            context?.strokePath()
        }
    }
}

extension Line {
    func bezier() -> UIBezierPath {
        let path = UIBezierPath()
        let points = self.points.sampled(atLength: 10)
        guard points.count > 1 else {
            return path
        }

        path.move(to: points[0])

        let first = 0
        let last = points.count - 2
        for (idx, point) in points.enumerated().dropLast() {
            let next = points[idx + 1]
            let midCurrent = point.midPoint(between: next)
            if idx == first {
                path.addLine(to: midCurrent)
            } else if idx == last {
                path.addLine(to: next)
            } else {
                path.addQuadCurve(to: midCurrent, controlPoint: point)
            }
        }

        return path
    }
}
