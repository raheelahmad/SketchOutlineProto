//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 4/4/21.
//

import SwiftUI
import Models
import Combine

public final class Coordinator {
    private var cancellables: [AnyCancellable] = []
    private let view: CanvasView

    init(view: CanvasView) {
        self.view = view
        DispatchQueue.main.async {
            do {
                view.model.nodes = try self.read()
            }
            catch { assertionFailure("Error reading \(error.localizedDescription)") }
        }
    }

    func bindRecognizers(canvasView: CanvasUIView) {
        canvasView.nodeRecognized
            .sink { [weak self] recognition in
                guard let self = self else { return }
                NodesReducer.nodeRecognition(
                    nodes: &self.view.model.nodes,
                    parentBounds: canvasView.bounds,
                    recognition: recognition
                )

                self.save()
            }.store(in: &cancellables)

        canvasView.linkRecognized.sink { [weak self] linkRecognition in
            guard let self = self else { return }
            NodesReducer.linkRecognition(
                nodes: &self.view.model.nodes,
                parentBounds: canvasView.bounds,
                recognition: linkRecognition
            )

            self.save()

        }.store(in: &cancellables)

        canvasView.textUpdated
            .sink { [weak self] update in
                guard let self = self else { return }

                NodesReducer.updateNode(nodes: &self.view.model.nodes, update: update)
                self.save()
            }.store(in: &cancellables)
    }

    private func save() {
        do { try self.write(self.view.model.nodes) }
        catch { assertionFailure("Error saving \(error.localizedDescription)") }
    }

    private let nodesStorageKey = "Nodes"
    private func read() throws -> [Node] {
        guard let nodesData = UserDefaults.standard.data(forKey: nodesStorageKey)
        else {
            return []
        }

        let nodes = try JSONDecoder().decode([Node].self, from: nodesData)
        return nodes
    }
    private func write(_ nodes: [Node]) throws {
        let data = try JSONEncoder().encode(nodes)
        UserDefaults.standard.setValue(data, forKey: nodesStorageKey)
    }
}

public final class CanvasViewModel: ObservableObject {
    @Published var nodes: [Node] = []
    @Published public var autolayout = false

    private var cancellables: [AnyCancellable] = []

    public init() {

    }
}

public struct CanvasView: UIViewRepresentable {
    @ObservedObject var model: CanvasViewModel

    public func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }

    public init(model: CanvasViewModel) {
        self.model = model
    }

    public func makeUIView(context: Context) -> CanvasUIView {
        let view = CanvasUIView(model: model)
        context.coordinator.bindRecognizers(canvasView: view)
        return view
    }

    public func updateUIView(_ uiView: CanvasUIView, context: Context) {
        uiView.update(model.nodes)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView(model: CanvasViewModel())
    }
}

