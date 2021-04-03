//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/28/21.
//

import Foundation
import UIKit

extension Line {
    func draw(with context: CGContext?) {
        let path = UIBezierPath()
        path.move(to: points[0])

        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        context?.addPath(path.cgPath)
        context?.strokePath()
    }
}
