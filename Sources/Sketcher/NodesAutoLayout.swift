import CoreGraphics
import NodeView
import Models

protocol LayoutNode {
    var id: String { get }
    var childNodeIds: Set<String> { get }
    var fractPos: Position { get set }
}

extension Node: LayoutNode {
    var childNodeIds: Set<String> { linkedNodeIds }
}

struct LayoutNodeSiblings: CustomDebugStringConvertible {
    let parentId: String?
    let siblings: [LayoutNode]

    var debugDescription: String {
        "parentId: \(parentId ?? ""), siblingIds: \(siblings.map {$0.id}.joined(separator: " "))"
    }
}

class NodesAutoLayout {
    struct Metrics {
        let nodeSize: CGSize
        let nodeSpacingX: CGFloat
        let nodeSpacingY: CGFloat

        let interSiblingsSpacing: CGFloat

        let rowSpacing: CGFloat

    }

    static func layout(nodes: [LayoutNode], m: Metrics) {

    }

    static func tree(from nodes: [LayoutNode]) -> [[LayoutNodeSiblings]] {
        func findChildren(node: LayoutNode) -> LayoutNodeSiblings {
            let children = nodes.filter { node.childNodeIds.contains($0.id) }
            return LayoutNodeSiblings(parentId: node.id, siblings: children)
        }

        var rootNodes = nodes.filter { node in
            !nodes.contains(where: { $0.childNodeIds.contains(node.id) })
        }
        var rootNodeSiblings = rootNodes.map {
            [LayoutNodeSiblings(parentId: nil, siblings: [$0])]
        }

        while !rootNodes.isEmpty {
            let siblings = rootNodes.map { findChildren(node: $0) }
            rootNodeSiblings.append(siblings)
            rootNodes = siblings
                .flatMap { $0.siblings
                    .filter { node in !node.childNodeIds.isEmpty } // only include non-leaf nodes as next root node
                }
        }

        return rootNodeSiblings
    }
}
