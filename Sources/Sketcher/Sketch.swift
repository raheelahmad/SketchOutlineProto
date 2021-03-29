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

    let tangentSlider = UISlider()
    let angleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    var showsTangents: Bool = true
    var showsMultipleLines: Bool = true

    private func setup() {
        guard showsTangents else {
            return
        }

        tangentSlider.minimumValue = 0
        tangentSlider.addTarget(self, action: #selector(tangentSliderMoved), for: .valueChanged)
        tangentSlider.addTarget(self, action: #selector(tangentSliderEnded), for: .touchUpInside)
        tangentSlider.addTarget(self, action: #selector(tangentSliderEnded), for: .touchUpOutside)
        tangentSlider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tangentSlider)
        NSLayoutConstraint.activate([
            tangentSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tangentSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20)
        ])
        angleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(angleLabel)
        NSLayoutConstraint.activate([
            angleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            angleLabel.topAnchor.constraint(equalTo: tangentSlider.bottomAnchor, constant: 20)
        ])
    }

    private var tangentSliderIndex: Int? {
        didSet {
            setNeedsDisplay()
            if tangentSliderIndex != oldValue {
                updateAngle()
            }
        }
    }

    @objc
    private func tangentSliderMoved() {
        let index = Int(tangentSlider.value)
        tangentSliderIndex = index
    }

    @objc
    private func tangentSliderEnded() {
        tangentSliderIndex = nil
        tangentSlider.value = 0
    }

    func updateAngle() {
        guard let index = tangentSliderIndex else {
            return
        }
        guard let angle = currentLine.angles.first(where: { $0.index == index }) else { return }
        angleLabel.text = String(format: "%.2f", angle.angle)
        if angle.isMajorTurn {
            print(String(format: "Major turn at %.2f (%.2f) [%d]", angle.angle, angle.normalized, angle.index))
        }
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append(currentLine)
        currentLine = Line(id: Date().description, points: [])

        if !showsMultipleLines {
            lines.removeAll()
        }
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
        currentLine.recognized = currentLine.figureOutShape()

        currentLine.calculateAngles()
    }

    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.gray.cgColor)
        context?.fill(bounds)

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

    }

    func addAngleTexts() {
        for layer in layer.sublayers!.filter({ $0 is CATextLayer }) {
            layer.removeFromSuperlayer()
        }

        let fm = NumberFormatter()
        fm.maximumFractionDigits = 1

        for (idx, slope) in currentLine.slopes.enumerated() {
            let slopeTextLayer = CATextLayer()
            let currentSlope = atan(Double(slope.slope))
            let slopeText = fm.string(from: NSNumber(value: currentSlope))!
            slopeTextLayer.string = slopeText
            slopeTextLayer.font = UIFont.systemFont(ofSize: 12, weight: .thin)
            slopeTextLayer.fontSize = 10
            layer.addSublayer(slopeTextLayer)
            let position = currentLine.points[slope.index]
            slopeTextLayer.frame = .init(x: position.x - 20 , y: position.y - 10, width: 30, height: 20)

            if idx > 0 {
                let diffTextLayer = CATextLayer()
                let previousSlope = atan(Double(currentLine.slopes[idx - 1].slope))
                let diff = abs(abs(currentSlope) - abs(previousSlope))
                let diffThreshold = 0.6
                if diff < diffThreshold {
                    continue
                }

                let deltaSlopeText = fm.string(from: NSNumber(value: diff))!
                let diffText = "  [\(fm.string(from: NSNumber(value: currentSlope))!) • \(fm.string(from: NSNumber(value: previousSlope))!)]"
                diffTextLayer.string = deltaSlopeText + diffText
                diffTextLayer.font = UIFont.systemFont(ofSize: 12, weight: .bold)
                diffTextLayer.fontSize = 10
                layer.addSublayer(diffTextLayer)
                let position = currentLine.points[slope.index]
                diffTextLayer.frame = .init(x: position.x + 20, y: position.y-10, width: 90, height: 20)
            }
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

