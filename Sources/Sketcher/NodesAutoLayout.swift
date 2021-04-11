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
    var siblings: [LayoutNode]

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

    static func layout(nodes: inout [LayoutNode], m: Metrics) {
        var tree = self.tree(from: nodes)

        var x: CGFloat = m.interSiblingsSpacing
        var y: CGFloat = m.rowSpacing

        for (levelIdx, var level) in tree.enumerated() {
            for (groupIdx, var siblingGroup) in level.enumerated() {
                for (siblingIdx, var sibling) in siblingGroup.siblings.enumerated() {
                    sibling.fractPos = Position(x: Double(x), y: Double(y))
                    siblingGroup.siblings[siblingIdx] = sibling
                    x += m.nodeSpacingX
                }

                x += m.interSiblingsSpacing

                level[groupIdx] = siblingGroup
            }

            y += (m.nodeSize.height + m.nodeSpacingY)
            x = 0
            tree[levelIdx] = level
        }

        for treeItem in tree {
            for siblings in treeItem.map({ $0.siblings}) {
                for node in siblings {
                    let idx = nodes.firstIndex(where: { $0.id == node.id })!
                    nodes[idx] = node
                }
            }
        }
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
