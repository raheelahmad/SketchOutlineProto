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
    let id: String
    var points: [CGPoint]
}

public final class Sketcher: UIView {
    var lines: [Line] = []
    var currentLine = Line(id: Date().description, points: []) {
        didSet {
            tangentSlider.maximumValue = Float(currentLine.points.count)
            print(tangentSlider.maximumValue)
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
                let size: CGFloat = isSelectedForTangent ? 8 : 4
                context?.fillEllipse(in: CGRect(x: point.x - size , y: point.y - size, width: size*2, height: size*2))
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SketchDemoView()
    }
}

