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
    var points: [CGPoint]
}

public final class Sketcher: UIView {
    var lines: [Line] = []
    var currentPoints: [CGPoint] = []

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentPoints.removeAll()
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch touches.count {
        case 0:
            return
        case 1:
            currentPoints.append(touches.first!.location(in: self))
        default:
            let touchedPoints = touches
               .map { $0.location(in: self) }
            let closestTouched = currentPoints.last.flatMap { last in
                touchedPoints
                    .min(by: { $0.distance(to: last) > $1.distance(to: last) })
            }
            currentPoints.append(closestTouched ?? touchedPoints[0])
        }

        setNeedsDisplay()
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !currentPoints.isEmpty else {
            return
        }
        let line = Line(points: currentPoints)
        lines.append(line)
        currentPoints.removeAll()
        setNeedsDisplay()
    }

    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        var linePoints = lines.map { $0.points }
        linePoints += [currentPoints]
        for points in linePoints {
            guard !points.isEmpty else { continue }
            let path = UIBezierPath()
            path.move(to: points[0])

            for point in points.dropFirst() {
                path.addLine(to: point)
            }

            context?.addPath(path.cgPath)
            context?.setStrokeColor(UIColor.red.cgColor)

            context?.strokePath()
        }

        context?.setFillColor(UIColor.red.cgColor)

        let allPoints = linePoints.flatMap { $0 }
        for point in allPoints {
            let size: CGFloat = 4
            context?.fillEllipse(in: CGRect(x: point.x - size , y: point.y - size, width: size*2, height: size*2))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SketchDemoView()
    }
}

