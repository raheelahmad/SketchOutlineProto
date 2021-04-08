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

        let halfX = abs(b.x - a.x)/2.0
        let halfY = abs(b.y - a.y)/2.0

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

/// Also indicates the position of the "from" node.
enum LinkArcStrategy {
    case topRight
    case right
    case bottomRight
    case bottom
    case bottomLeft
    case left
    case topLeft
    case top
}

extension CGRect {
    static func linkPoints(from a: Self, to b: Self) -> (CGPoint, CGPoint) {
        let strategy = linkArcStrategyBetween(from: a, to: b)
        let f, t: CGPoint
        switch strategy {
        case .top:
            f = CGPoint(x: a.midX, y: a.minY)
            t = CGPoint(x: b.midX, y: b.maxY)
        case .topRight:
            f = CGPoint(x: a.maxX, y: a.midY)
            t = CGPoint(x: b.midX, y: b.maxY)
        case .right:
            f = CGPoint(x: a.maxX, y: a.midY)
            t = CGPoint(x: b.minX, y: b.midY)
        case .bottomRight:
            f = CGPoint(x: a.midX, y: a.maxY)
            t = CGPoint(x: b.minX, y: b.midY)
        case .bottom:
            f = CGPoint(x: a.midX, y: a.maxY)
            t = CGPoint(x: b.midX, y: b.minY)
        case .bottomLeft:
            f = CGPoint(x: a.midX, y: a.maxY)
            t = CGPoint(x: b.maxX, y: b.midY)
        case .left:
            f = CGPoint(x: a.minX, y: a.midY)
            t = CGPoint(x: b.maxX, y: b.midY)
        case .topLeft:
            f = CGPoint(x: a.minX, y: a.midY)
            t = CGPoint(x: b.midX, y: b.maxY)
        }
        return (f, t)
    }
    static func linkArcStrategyBetween(from a: CGRect, to b: CGRect) -> LinkArcStrategy {
        // where is b in relation to a
        let above = b.maxY < a.minY
        let below = b.minY > a.maxY

        let left = b.maxX < a.minX
        let right = b.minX > a.maxX

        if above {
            if right {
                return .topRight
            } else if left {
                return .topLeft
            } else {
                return .top
            }
        } else if below {
            if right {
                return .bottomRight
            } else if left {
                return .bottomLeft
            } else {
                return .bottom
            }
        } else {
            // just check if it's left vs. right via the centers of the rects, rather than the extremities
            if b.midX > a.midX {
                return .right
            } else {
                return .left
            }
        }
    }
}
