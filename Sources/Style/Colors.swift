//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/20/21.
//

import SwiftUI

extension Color {
    public static var primaryBackground: Color {
        hex(0x929299)
    }
}

extension Gradient {
    public static var statusOverlay: Gradient {
        .init(colors: [Color.hex(0xE0DDF5), Color.hex(0xEEEDF3)])
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


