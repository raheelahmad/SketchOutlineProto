//
//  SketchDemoApp.swift
//  SketchDemo
//
//  Created by Raheel Ahmad on 3/22/21.
//

import SwiftUI
import Sketcher

struct SketchDemoView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        Sketcher(frame: .zero)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

@main
struct SketchDemoApp: App {
    var body: some Scene {
        WindowGroup {
            SketchDemoView()
        }
    }
}
