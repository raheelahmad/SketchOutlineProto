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

    init() {
        super.init(frame: .zero)

    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        startDrawing(with: point)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        addToDrawing(point)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finalizeDrawing()
    }
}

extension CanvasUIView {
    private func finalizeDrawing() {
        guard var line = currentLine else {
            return
        }
        line.resample(atLength: 20)
        line.calculateAngles()
        if let rect = line.boundingRect {
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
        self.currentLine = nil
    }

    private func startDrawing(with point: CGPoint) {
        currentLine = Line(id: UUID().uuidString, points: [point])
        endEditing(true)
    }

    private func addToDrawing(_ point: CGPoint) {
        assert(currentLine != nil)
        currentLine?.points.append(point)
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

        if let p = currentLine?.bezier() {
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
