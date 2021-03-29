//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/28/21.
//

import Foundation
import CoreGraphics

extension Line.PointAngle {
    var normalized: CGFloat {
        abs(CGFloat.pi - abs(angle)).truncatingRemainder(dividingBy: CGFloat.pi)
    }
    var isMajorTurn: Bool {
        let threshold = CGFloat.pi / 4.5 // 45 degrees
        return normalized > threshold
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
        var dist: CGFloat = 0
        var sampled: [CGPoint] = []
        for (idx, point) in points.dropFirst().enumerated() {
            dist += point.distance(to: points[idx])
            if dist >= length {
                sampled.append(point)
                dist = 0
            }
        }

        print("Sampled \(points.count) → \(sampled.count)")
        self.points = sampled
    }
}
