//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/28/21.
//

import CoreGraphics

struct Line {
    struct PointSlope {
        let index: Int
        let slope: CGFloat
    }

    struct PointAngle: CustomDebugStringConvertible {
        let index: Int
        let angle: CGFloat

        var debugDescription: String {
            "\(index): ⌳ \(angle)"
        }
    }

    let id: String
    var points: [CGPoint] {
        didSet { calculateSlopes() }
    }

    var slopes: [PointSlope] = []
    var angles: [PointAngle] = []
}

