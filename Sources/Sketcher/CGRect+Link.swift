//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 4/9/21.
//

import CoreGraphics

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
    public static func linkPoints(from a: Self, to b: Self) -> (CGPoint, CGPoint) {
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
