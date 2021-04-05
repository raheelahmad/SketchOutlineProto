//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/28/21.
//

import Foundation
import UIKit

extension Line {
    func draw(with context: CGContext?) {
        let path = UIBezierPath()
        path.move(to: points[0])

        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        context?.addPath(path.cgPath)
        context?.strokePath()
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
