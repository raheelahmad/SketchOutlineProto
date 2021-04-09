//
//  SketchDemoApp.swift
//  SketchDemo
//
//  Created by Raheel Ahmad on 3/22/21.
//

import SwiftUI
import SketchStatusView
import Sketcher

let canvasModel = CanvasViewModel()

@main
struct SketchDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topTrailing) {
                CanvasView(model: canvasModel)
                SketchStatusView.SketchMenuView(items: [.init(title: "Auto layout", imageName: "perspective")]) { selection in
                    canvasModel.autolayout = true
                }
            }
        }
    }
}


struct SketchView_Previews: PreviewProvider {
    static var previews: some View {
        SketchDemoView()
    }
}
