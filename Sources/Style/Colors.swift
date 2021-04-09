//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/20/21.
//

import SwiftUI

extension Color {
    public static var primaryBackground: Color { Color(UIColor.primaryBackground) }

    public static var gray0105: Color { Color(UIColor.gray0105) }

    public static var blueMed: Color { Color(UIColor.blueMed) }
}

extension UIColor {
    public static var primaryBackground: UIColor { hex(0xE0DDF5) }

    public static var gray0105: UIColor { hex(0xEBEBEB) }

    public static var blueMed: UIColor { hex(0x6C8FB8) }
}

extension Gradient {
    public static var statusOverlay: Gradient {
        .init(colors: [Color.hex(0xE0DDF5), Color.hex(0xEEEDF3)])
    }
}

extension UIColor {

    public static func hex(_ hex: UInt) -> UIColor {
        UIColor(
            red: CGFloat((hex & 0xff0000) >> 16) / 255,
            green: CGFloat((hex & 0x00ff00) >> 8) / 255,
            blue: CGFloat(hex & 0x0000ff) / 255,
            alpha: 1
        )
    }
}

extension Color {
  public static func hex(_ hex: UInt) -> Self {
    Self(
      red: Double((hex & 0xff0000) >> 16) / 255,
      green: Double((hex & 0x00ff00) >> 8) / 255,
      blue: Double(hex & 0x0000ff) / 255,
      opacity: 1
    )
  }
}

#if os(iOS)
import UIKit
#endif


