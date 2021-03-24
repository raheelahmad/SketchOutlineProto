//
//  SketchDemoApp.swift
//  SketchDemo
//
//  Created by Raheel Ahmad on 3/22/21.
//

import SwiftUI
import Sketcher

@main
struct SketchDemoApp: App {
    var body: some Scene {
        WindowGroup {
            SketchDemoView()
        }
    }
}


struct SketchView_Previews: PreviewProvider {
    static var previews: some View {
        SketchDemoView()
    }
}
