//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/28/21.
//

import CoreGraphics
import Foundation

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
        while currentIndex < points.count - 2 {
            currentIndex += 1
            dist += points[currentIndex].distance(to: points[currentIndex-1])
            if dist >= minWalkDist {
                let index = currentIndex
                let a = points[index - 1]
                let b = points[index + 1]
                let dx = b.x > a.x ? (b.x - a.x) : (a.x - b.x)
                let dy = b.x > a.x ? (b.y - a.y) : (a.y - b.y)
                let m = abs(dx) < 0.1 ? 1990 : -dy / dx
                slopes.append(PointSlope(index: currentIndex, slope: m))
                dist = 0
            }
        }

        self.slopes = slopes
    }
    func figureOutShape() -> [CGPoint] {
        //        let angles = slopes.map { atan($0.slope) }
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 3
        var points: [CGPoint] = [self.points[slopes.first!.index]]
        for (lastPoint, currentPoint) in zip(slopes.dropLast(), slopes.dropFirst()) {
            let last = atan(lastPoint.slope)
            let current = atan(currentPoint.slope)
            let diff = abs(current) - abs(last)
            if abs(diff) > 0.6 {
                let dir = current > last ? "+" : "-"
                print(dir + "\t\(nf.string(for: currentPoint.slope)) → \(nf.string(for: lastPoint.slope))")
                points.append(self.points[currentPoint.index])
            }
        }
        points.append(self.points.last!)
        return points
    }
}

extension NumberFormatter {
    func string(for value: CGFloat) -> String {
        string(from: NSNumber(value: Double(value)))!
    }
}
