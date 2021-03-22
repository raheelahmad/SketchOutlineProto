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
}
