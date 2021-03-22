//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/21/21.
//

import UIKit

final class Sketcher: UIView {
    var points: [CGPoint] = []

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        points.removeAll()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch touches.count {
        case 0:
            return
        case 1:
            points.append(touches.first!.location(in: self))
        default:
            let touchedPoints = touches
               .map { $0.location(in: self) }
            let closestTouched = points.last.flatMap { last in
                touchedPoints
                    .min(by: { $0.distance(to: last) > $1.distance(to: last) })
            }
            points.append(closestTouched ?? touchedPoints[0])
        }
    }

    override func draw(_ rect: CGRect) {
        guard !points.isEmpty else { return }

        let path = UIBezierPath()
        path.move(to: points[0])

        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        let context = UIGraphicsGetCurrentContext()

        context?.addPath(path.cgPath)
        context?.setStrokeColor(UIColor.red.cgColor)

        context?.strokePath()
    }
}
