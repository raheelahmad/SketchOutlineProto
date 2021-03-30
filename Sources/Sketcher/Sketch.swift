//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/21/21.
//

import UIKit
import SwiftUI

public struct SketchDemoView: UIViewRepresentable {
    public init() {}

    public func makeUIView(context: Context) -> some UIView {
        Sketcher(frame: .zero)
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

public final class Sketcher: UIView {
    var lines: [Line] = []
    var currentLine = Line(id: Date().description, points: []) {
        didSet {
            tangentSlider.maximumValue = Float(currentLine.points.count)
        }
    }

    let showsDebug = false

    var tangentSliderIndex: Int? {
        didSet {
            setNeedsDisplay()
            if tangentSliderIndex != oldValue { updateAngle() }
        }
    }

    let tangentSlider = UISlider()
    let angleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupDebugUI()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDebugUI()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append(currentLine)
        currentLine = Line(id: Date().description, points: [])
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch touches.count {
        case 0:
            return
        case 1:
            currentLine.points.append((touches.first!.location(in: self)))
        default:
            let touchedPoints = touches
               .map { $0.location(in: self) }
            let closestTouched = currentLine.points.last.flatMap { last in
                touchedPoints
                    .min(by: { $0.distance(to: last) > $1.distance(to: last) })
            }
            currentLine.points.append(closestTouched ?? touchedPoints[0])
        }

        setNeedsDisplay()
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setNeedsDisplay()
        currentLine.resample(atLength: 20)
        currentLine.calculateSlopes()
        currentLine.calculateAngles()
    }

    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.gray.cgColor)
        context?.fill(bounds)

        context?.setLineWidth(2)
        for line in (lines + [currentLine]) {

            let linePoints = line.points
            guard !linePoints.isEmpty else { continue }

            context?.setFillColor(UIColor.red.cgColor)

            for (idx, point) in linePoints.enumerated() {
                let isSelectedForTangent = line.id == currentLine.id && tangentSliderIndex == idx
                let isMega = isSelectedForTangent
                let size: CGFloat = isMega ? 4 : 1

                if isMega {
                    context?.strokeEllipse(in: CGRect(x: point.x - size , y: point.y - size, width: size*2, height: size*2))
                } else {
                    context?.fillEllipse(in: CGRect(x: point.x - size , y: point.y - size, width: size*2, height: size*2))
                }
            }

            line.draw(with: context)
        }

        if let boundingRect = currentLine.boundingRect {
            context?.setLineWidth(5)
            context?.setStrokeColor(UIColor.yellow.cgColor)
            context?.stroke(boundingRect)
        }

    }

    private func drawTangent(pointIndex: Int, line: Line, ctx: CGContext?) {
        let point = line.points[pointIndex]
        let m = line.tangent(at: pointIndex)

        let path = UIBezierPath()
        for (idx, offset) in (-120..<120).enumerated() {
            let offsetX = CGFloat(offset)
            let offsetY = offsetX * m
            let tPt = CGPoint(x: point.x + offsetX, y: point.y + offsetY)
            if idx == 0 {
                path.move(to: tPt)
            } else {
                path.addLine(to: tPt)
            }
        }

        ctx?.addPath(path.cgPath)
        ctx?.strokePath()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SketchDemoView()
    }
}

