import NodeView
import Models
import Foundation
import CoreGraphics

final class NodesReducer {
    static func linkRecognition(nodes: inout [Node], parentBounds: CGRect, recognition: LinkRecognition) {
        var updatedNodes = nodes
        switch recognition {
        case .fromTo(let fromNodeId, let toNodeId):
            guard
                let fromNodeIndex = updatedNodes.firstIndex(where: { $0.id == fromNodeId }),
                updatedNodes.contains(where: { $0.id == toNodeId })
            else {
                assertionFailure("Could not find nodes")
                return
            }

            var fromNode = updatedNodes[fromNodeIndex]
            fromNode.linkedNodeIds.insert(toNodeId)
            updatedNodes[fromNodeIndex] = fromNode
        case let .onlyFrom(fromNodeId, to):
            guard
                let fromNodeIndex = updatedNodes.firstIndex(where: { $0.id == fromNodeId })
            else {
                assertionFailure("Could not find node")
                return
            }

            let toNode = newNode(at: to, parentBounds: parentBounds)
            var fromNode = updatedNodes[fromNodeIndex]

            fromNode.linkedNodeIds.insert(toNode.id)
            updatedNodes.append(toNode)
            updatedNodes[fromNodeIndex] = fromNode
        }

        nodes = updatedNodes
    }

    static func nodeRecognition(nodes: inout [Node], parentBounds: CGRect, recognition: NodeRecognition) {
        let node = newNode(at: recognition.center, parentBounds: parentBounds)
        nodes.append(node)
    }

    private static func newNode(at point: CGPoint, parentBounds: CGRect) -> Node {
        let posX =  point.x / parentBounds.width
        let posY = point.y / parentBounds.height

        let colorHex = ["454440", "409D8F", "F92943", "F3C6B8"].randomElement()!
        let node = Node(
            id: UUID().uuidString,
            title: "",
            colorHex: colorHex,
            fractPos: .init(x: Double(posX), y: Double(posY)),
            linkedNodeIds: []
        )
        return node
    }

    static func updateNode(nodes: inout [Node], update: NodeUpdate) {
        guard let nodeIndex = nodes.firstIndex(where: { $0.id == update.id }) else {
            assertionFailure("Could not find node after text update")
            return
        }

        switch update.kind {
        case .position(let pos):
            nodes[nodeIndex].fractPos = pos
        case .text(let text):
            nodes[nodeIndex].title = text
        }
    }
}
