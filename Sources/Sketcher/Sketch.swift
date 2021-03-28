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

struct Line {
    struct PointSlope {
        let index: Int
        let slope: CGFloat
    }

    let id: String
    var points: [CGPoint] {
        didSet { calculateSlopes() }
    }

    var slopes: [PointSlope] = []
}

public final class Sketcher: UIView {
    var lines: [Line] = []
    var currentLine = Line(id: Date().description, points: []) {
        didSet {
            tangentSlider.maximumValue = Float(currentLine.points.count)
        }
    }

    let tangentSlider = UISlider()

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
    }

    private var tangentSliderIndex: Int? {
        didSet { setNeedsDisplay() }
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
        print(currentLine.length)
        currentLine.calculateSlopes()
    }

    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.gray.cgColor)
        context?.fill(bounds)

        for line in (lines + [currentLine]) {

            let linePoints = line.points
            guard !linePoints.isEmpty else { continue }
            let path = UIBezierPath()
            path.move(to: linePoints[0])

            for point in linePoints.dropFirst() {
                path.addLine(to: point)
            }

            context?.addPath(path.cgPath)
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.strokePath()


            context?.setFillColor(UIColor.red.cgColor)

            for (idx, point) in linePoints.enumerated() {
                let isSelectedForTangent = line.id == currentLine.id && tangentSliderIndex == idx
                let isUsedForAngleCalculations = line.id == currentLine.id && line.slopes.contains(where: { $0.index == idx })
                let isMega = isSelectedForTangent || isUsedForAngleCalculations
                let size: CGFloat = isMega ? 4 : 1

                if isMega {
                    context?.strokeEllipse(in: CGRect(x: point.x - size , y: point.y - size, width: size*2, height: size*2))
                } else {
                    context?.fillEllipse(in: CGRect(x: point.x - size , y: point.y - size, width: size*2, height: size*2))
                }

            }
        }

        if let index = tangentSliderIndex {
            drawTangent(pointIndex: index, line: currentLine, ctx: context)
        }

        addAngleTexts()
    }

    private func addAngleTexts() {
//        for texts =
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
                let diff = abs(currentSlope - previousSlope)
                let diffThreshold = 1.0
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

extension Line {
    func tangent(at index: Int) -> CGFloat {
        let slopeDist = 10
        let aIdx = max(0, index - slopeDist)
        let bIdx = min(points.count - 1, index + slopeDist)
        let a = points[aIdx]
        let b = points[bIdx]
        let m = a.x == b.x ? 1.0 : (a.y - b.y)/(a.x - b.x)

        return m
    }

    var length: CGFloat {
        guard points.count > 1 else { return 0 }
        return points.dropFirst()
            .enumerated()
            .reduce(0) { (accum, value) -> CGFloat in
                let idx = value.offset
                let point = value.element
                let previousPoint = points[idx]
                return accum + point.distance(to: previousPoint)
            }
    }

    mutating func calculateSlopes() {
        guard points.count > 3 else { return }

        let minWalkDist: CGFloat = 20
        var dist: CGFloat = 0
        var currentIndex = 0

        var slopes: [PointSlope] = []

        let fm = NumberFormatter()
        fm.maximumFractionDigits = 3
        func f(_ m: CGFloat) -> String {
            fm.string(from: NSNumber(value: Double(m)))!
        }
        print("----------------")
        while currentIndex < points.count - 2 {
            currentIndex += 1
            dist += points[currentIndex].distance(to: points[currentIndex-1])
            if dist >= minWalkDist {
                let index = currentIndex
                let a = points[index - 1]
                let b = points[index + 1]
                let dx = b.x > a.x ? (b.x - a.x) : (a.x - b.x)
                let dy = b.x > a.x ? (b.y - a.y) : (a.y - b.y)
                if abs(dx) <= 0.5 && !slopes.isEmpty { continue }
                let m = -dy / dx
                print("\(f(b.x))\t\(f(b.y)) \t\t \(f(a.x))\t\(f(a.y))  \t\t\t\t \(f(m)) \(f(atan(m)))")
                slopes.append(PointSlope(index: currentIndex, slope: m))
                dist = 0
            }
        }
        print("===============")

        self.slopes = slopes
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SketchDemoView()
    }
}

