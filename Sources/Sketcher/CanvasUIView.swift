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
            // TODO: both these can be factored out as reducers:
            // reduceNodeRecognition: inout [Node], recognition: NodeRecognition
            // reduceLinkRecognition: inout [Node], recognition: LinkRecognition
            canvasView.nodeRecognized
                .sink { [weak self] recognition in
                    guard let self = self else { return }

                    let posX =  recognition.center.x / canvasView.bounds.width
                    let posY = recognition.center.y / canvasView.bounds.height
                    let node = Node(
                        id: UUID().uuidString,
                        title: "",
                        colorHex: "8312A8",
                        fractPos: .init(x: Double(posX), y: Double(posY)),
                        linkedNodeIds: []
                    )
                    self.view.nodes.append(node)
                }.store(in: &cancellables)

            canvasView.linkRecognized.sink { [weak self] linkRecognition in
                guard let self = self else { return }
                var nodes = self.view.nodes

                switch linkRecognition {
                case .fromTo(let fromNodeId, let toNodeId):
                    guard
                        let fromNodeIndex = nodes.firstIndex(where: { $0.id == fromNodeId }),
                        nodes.contains(where: { $0.id == toNodeId })
                    else {
                        assertionFailure("Could not find nodes")
                        return
                    }

                    var fromNode = nodes[fromNodeIndex]
                    fromNode.linkedNodeIds.insert(toNodeId)
                    nodes[fromNodeIndex] = fromNode
                case let .onlyFrom(fromNodeId, to):
                    guard
                        let fromNodeIndex = nodes.firstIndex(where: { $0.id == fromNodeId })
                    else {
                        assertionFailure("Could not find node")
                        return
                    }

                    let posX =  to.x / canvasView.bounds.width
                    let posY = to.y / canvasView.bounds.height
                    var fromNode = nodes[fromNodeIndex]
                    let toNode = Node(
                        id: UUID().uuidString,
                        title: "",
                        colorHex: "8218AD",
                        fractPos: .init(x: Double(posX), y: Double(posY)),
                        linkedNodeIds: []
                    )
                    fromNode.linkedNodeIds.insert(toNode.id)
                    nodes.append(toNode)
                    nodes[fromNodeIndex] = fromNode
                }

                self.view.nodes = nodes
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

