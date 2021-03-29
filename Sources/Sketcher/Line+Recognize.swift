//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/28/21.
//

import Foundation
import CoreGraphics

extension Line {
    var boundingRect: CGRect? {
        let majorAnglePoints = angles.filter { $0.isMajorTurn }
        guard majorAnglePoints.count == 3 else {
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
