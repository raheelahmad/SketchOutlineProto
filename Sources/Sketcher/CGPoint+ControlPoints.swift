//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/21/21.
//

import CoreGraphics

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        let squaredSum = pow(self.x - other.x, 2) + pow(self.y - other.y, 2)
        return sqrt(squaredSum)
    }

    static func controlPoints(between a: CGPoint, and b: CGPoint) -> (CGPoint, CGPoint) {
        enum Position {
            case upAndLeft, upAndRight
            case downAndLeft, downAndRight
        }
        let position: Position
        switch (b.x - a.x > 0, b.y - a.y > 0) {
        case (false, false):
            position = .upAndLeft
        case (false, true):
            position = .downAndLeft
        case (true, false):
            position = .upAndRight
        case (true, true):
            position = .downAndRight
        }

        let halfX = abs(b.x - a.x)/3.0
        let halfY = abs(b.y - a.y)/3.0

        switch position {
        case .upAndLeft:
            return (
                CGPoint(x: a.x - halfX , y: a.y),
                CGPoint(x: b.x, y: b.y + halfY)
            )
        case .upAndRight:
            return (
                CGPoint(x: a.x + halfX , y: a.y),
                CGPoint(x: b.x, y: b.y + halfY)
            )
        case .downAndLeft:
            return (
                CGPoint(x: a.x , y: a.y + halfY),
                CGPoint(x: a.x - halfX, y: b.y)
            )
        case .downAndRight:
            return (
                CGPoint(x: a.x , y: a.y + halfY),
                CGPoint(x: a.x + halfX, y: b.y)
            )
        }
    }

    func midPoint(between second: CGPoint) -> CGPoint {
        .init(x: (second.x + x)/2, y: (second.y + y)/2)
    }
}
