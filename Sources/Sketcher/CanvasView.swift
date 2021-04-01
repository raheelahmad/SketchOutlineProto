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

    private func finalizeDrawing() {
        guard var line = currentLine else {
            return
        }
        line.resample(atLength: 20)
        line.calculateAngles()
        if let rect = line.boundingRect {
            let nodeView = NodeView.NodeUIView()
            addSubview(nodeView)
            nodeView.center = CGPoint(x: rect.midX, y: rect.midY)
            self.views.append(nodeView)
            DispatchQueue.main.async {
                nodeView.activate()
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

extension CanvasUIView {
    override func draw(_ rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(rect)

        context?.setFillColor(UIColor.red.cgColor)
        guard let linePoints = currentLine?.points else {
            return
        }

        for point in linePoints {
            let size: CGFloat = 1
            context?.fillEllipse(in: CGRect(x: point.x - size , y: point.y - size, width: size*2, height: size*2))
        }
    }
}
