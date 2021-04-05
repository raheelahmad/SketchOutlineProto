//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 4/4/21.
//

import SwiftUI
import Combine

public struct CanvasView: UIViewRepresentable {
    @State var nodes: [Node] = []

    public func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }

    public final class Coordinator {
        private var cancellables: [AnyCancellable] = []
        private let view: CanvasView

        init(view: CanvasView) {
            self.view = view
        }

        func bindRecognizers(canvasView: CanvasUIView) {
            canvasView.nodeRecognized
                .sink { [weak self] recognition in
                    guard let self = self else { return }
                    NodesReducer.nodeRecognition(
                        nodes: &self.view.nodes,
                        parentBounds: canvasView.bounds,
                        recognition: recognition
                    )
                }.store(in: &cancellables)

            canvasView.linkRecognized.sink { [weak self] linkRecognition in
                guard let self = self else { return }
                NodesReducer.linkRecognition(
                    nodes: &self.view.nodes,
                    parentBounds: canvasView.bounds,
                    recognition: linkRecognition
                )
            }.store(in: &cancellables)
        }
    }

    public init() {}

    public func makeUIView(context: Context) -> CanvasUIView {
        let view = CanvasUIView()
        context.coordinator.bindRecognizers(canvasView: view)
        return view
    }

    public func updateUIView(_ uiView: CanvasUIView, context: Context) {
        uiView.update(nodes)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView()
    }
}

