import Foundation
import CoreGraphics
import Combine

import Models

final class CanvasViewModel {
    let nodes: CurrentValueSubject<[Node], Never>

    private static let nodesStorageKey = "Nodes"

    let nodeRecognized: AnyPublisher<NodeRecognition, Never>
    let linkRecognized: AnyPublisher<LinkRecognition, Never>
    let textUpdated: AnyPublisher<NodeUpdate, Never>

    let boundsUpdated: AnyPublisher<CGRect, Never>
    let autoLayout = PassthroughSubject<NodesAutoLayout.Metrics, Never>()

    private var cancellables: [AnyCancellable] = []

    init(
        nodeRecognized: AnyPublisher<NodeRecognition, Never>,
        linkRecognized: AnyPublisher<LinkRecognition, Never>,
        textUpdated: AnyPublisher<NodeUpdate, Never>,
        boundsUpdated: AnyPublisher<CGRect, Never>
    ) {
        self.nodes = .init([])
        self.nodeRecognized = nodeRecognized
        self.linkRecognized = linkRecognized
        self.textUpdated = textUpdated
        self.boundsUpdated = boundsUpdated

        DispatchQueue.main.async {
            do {
                self.nodes.value = try Self.read()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    func bindRecognizers() {
        nodeRecognized
            .combineLatest(boundsUpdated)
            .sink { [weak self] (recognition, canvasBounds) in
                guard let self = self else { return }
                var nodes = self.nodes.value

                NodesReducer.nodeRecognition(
                    nodes: &nodes,
                    parentBounds: canvasBounds,
                    recognition: recognition
                )

                self.nodes.value = nodes

                self.save()
            }.store(in: &cancellables)

        linkRecognized
            .combineLatest(boundsUpdated)
            .sink { [weak self] (linkRecognition, canvasBounds) in
            guard let self = self else { return }
                var nodes = self.nodes.value
                NodesReducer.linkRecognition(
                    nodes: &nodes,
                    parentBounds: canvasBounds,
                    recognition: linkRecognition
                )
                self.nodes.value = nodes

                self.save()

        }.store(in: &cancellables)

        textUpdated
            .sink { [weak self] update in
                guard let self = self else { return }

                var nodes = self.nodes.value

                NodesReducer.updateNode(nodes: &nodes, update: update)

                self.nodes.value = nodes

                self.save()
            }.store(in: &cancellables)

        autoLayout
            .sink { [weak self] metrics in
                guard let self = self else { return }
                var nodes = self.nodes.value
                NodesAutoLayout.layout(
                    nodes: &nodes,
                    m: metrics
                )
                self.nodes.value = nodes
                self.save()
            }.store(in: &cancellables)
    }
}

extension CanvasViewModel {
    private func save() {
        do { try Self.write(self.nodes.value) }
        catch { assertionFailure("Error saving \(error.localizedDescription)") }
    }

    private static func read() throws -> [Node] {
        guard let nodesData = UserDefaults.standard.data(forKey: nodesStorageKey)
        else {
            return []
        }

        let nodes = try JSONDecoder().decode([Node].self, from: nodesData)
        return nodes
    }

    private static func write(_ nodes: [Node]) throws {
        let data = try JSONEncoder().encode(nodes)
        UserDefaults.standard.setValue(data, forKey: nodesStorageKey)
    }
}
