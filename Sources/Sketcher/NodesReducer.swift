import NodeView
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

            let posX =  to.x / parentBounds.width
            let posY = to.y / parentBounds.height
            var fromNode = updatedNodes[fromNodeIndex]
            let toNode = Node(
                id: UUID().uuidString,
                title: "",
                colorHex: "8218AD",
                fractPos: .init(x: Double(posX), y: Double(posY)),
                linkedNodeIds: []
            )
            fromNode.linkedNodeIds.insert(toNode.id)
            updatedNodes.append(toNode)
            updatedNodes[fromNodeIndex] = fromNode
        }

        nodes = updatedNodes
    }

    static func nodeRecognition(nodes: inout [Node], parentBounds: CGRect, recognition: NodeRecognition) {
        let posX =  recognition.center.x / parentBounds.width
        let posY = recognition.center.y / parentBounds.height
        let node = Node(
            id: UUID().uuidString,
            title: "",
            colorHex: "8312A8",
            fractPos: .init(x: Double(posX), y: Double(posY)),
            linkedNodeIds: []
        )
        nodes.append(node)
    }
}
