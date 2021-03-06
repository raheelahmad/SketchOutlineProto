//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/28/21.
//

import Foundation
import CoreGraphics

/// These two are the crucial elements for recognition
extension Line.PointAngle {
    var normalized: CGFloat {
        abs(CGFloat.pi - abs(angle)).truncatingRemainder(dividingBy: CGFloat.pi)
    }
    static var minorThreshold: CGFloat { CGFloat.pi / 4.5 }
    static var majorThreshold: CGFloat { CGFloat.pi / 9.8 }
    static var megaThreshold: CGFloat { CGFloat.pi + 1.0 }

}

extension Line {
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
}

extension Line {
    mutating func calculateAngles() {
        guard points.count > 1 else {
            return
        }

        var angles: [PointAngle] = []
        let pts = points.dropFirst().dropLast()
        for (idx, point) in pts.enumerated() {
            let prev = points[idx]
            let next = points[idx+2]
            let angle = atan2(next.y - point.y, next.x - point.x) -
                atan2(prev.y - point.y, prev.x - point.x)

            angles.append(PointAngle(index: idx+1, angle: angle))
        }
        self.angles = angles
    }
}

extension Line {
    mutating func resample(atLength length: CGFloat) {
        let sampled = points.sampled(atLength: length)
        if sampled.isEmpty { return }

        self.points = sampled
    }
}

extension Array where Element == CGPoint {
    func sampled(atLength length: CGFloat) -> [CGPoint] {
        var dist: CGFloat = 0
        var sampled: [CGPoint] = []
        for (idx, point) in dropFirst().enumerated() {
            dist += point.distance(to: self[idx])
            if dist >= length {
                sampled.append(point)
                dist = 0
            }
        }
        return sampled
    }
}
