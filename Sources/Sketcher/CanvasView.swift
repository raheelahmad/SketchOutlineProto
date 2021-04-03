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

final class CanvasUIView: UIView {
    var currentLine: Line? = nil {
        didSet {
            setNeedsDisplay()
        }
    }

    private var views: [UIView] = [] {
        didSet {
            for view in views {
                addSubview(view)
            }
        }
    }

    lazy var nodeRecognizer = NodeRecognizer(target: self, action: #selector(nodeRecognition(recognizer:)))

    init() {
        super.init(frame: .zero)

        addGestureRecognizer(nodeRecognizer)
    }

    @objc
    private func nodeRecognition(recognizer: NodeRecognizer) {
        switch recognizer.state {
        case .recognized:
            if let line = recognizer.line?.boundingRect {
                addNode(in: line)
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
    private func addNode(in rect: CGRect) {
        let nodeView = NodeView.NodeUIView()
        let dragger = UIDragInteraction(delegate: self)
        nodeView.addInteraction(dragger)
        addSubview(nodeView)
        nodeView.center = CGPoint(x: rect.midX, y: rect.midY)
        self.views.append(nodeView)
        DispatchQueue.main.async {
            nodeView.activateEditing()
        }
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
