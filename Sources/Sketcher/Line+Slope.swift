//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/28/21.
//

import CoreGraphics
import Foundation

extension NumberFormatter {
    func string(for value: CGFloat) -> String {
        string(from: NSNumber(value: Double(value)))!
    }
}
