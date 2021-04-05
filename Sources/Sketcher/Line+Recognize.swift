//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/28/21.
//

import Foundation
import CoreGraphics

extension Line.PointAngle {
    func isAbove(_ threshold: CGFloat) -> Bool {
        normalized > threshold
    }
}

extension Line {
    func anglesAboveThreshold(_ threshold: CGFloat, minorThreshold: CGFloat) -> Int {
        var currentMinorCumulative: CGFloat = 0
        var majorCount = 0
        for (idx, angle) in angles.enumerated() {
            if angle.isAbove(threshold) {
//                ignore current one if previous two were also a major
                if idx > 0 && angles[idx-1].isAbove(threshold) { continue }
                if idx > 1 && angles[idx-2].isAbove(threshold) { continue }
                majorCount += 1
            } else if angle.isAbove(minorThreshold) {
                // could still have a cumulative major angle
                currentMinorCumulative += angle.angle
                let majorTestAngle = PointAngle(index: -1, angle: currentMinorCumulative)
                if majorTestAngle.isAbove(threshold) {
                    majorCount += 1
                    currentMinorCumulative = 0
                }
            } else {
                currentMinorCumulative = 0
            }
        }
        return majorCount
    }

    var boundingRect: CGRect? {
        let majorCount = anglesAboveThreshold(Line.PointAngle.majorThreshold, minorThreshold: Line.PointAngle.minorThreshold)

        guard majorCount == 3 else {
            return nil
        }

        let anglePoints = angles.map { points[$0.index] }
        let minX = anglePoints.min(by: { $0.x < $1.x })!.x
        let maxX = anglePoints.min(by: { $0.x > $1.x })!.x
        let minY = anglePoints.min(by: { $0.y < $1.y })!.y
        let maxY = anglePoints.min(by: { $0.y > $1.y })!.y

        let origin = CGPoint(x: minX, y: minY)
        let size = CGSize(width: maxX - minX, height: maxY - minY)
        return CGRect(origin: origin, size: size)
    }
}
