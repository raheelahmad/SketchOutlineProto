import CoreGraphics
import NodeView
import Models

extension Node {
    var childNodeIds: Set<String> { linkedNodeIds }
}

struct LayoutNodeSiblings: CustomDebugStringConvertible {
    let parentId: String?
    var siblings: [Node]

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

        let margins: CGSize
    }

    static func layout(nodes: inout [Node], m: Metrics) {
        var tree = self.tree(from: nodes)

        let left: CGFloat = m.margins.width + m.nodeSize.width / 2.0
        let bottom: CGFloat = 1 - m.nodeSize.height/2 - m.margins.height
        var x: CGFloat = left
        var y: CGFloat = bottom

        for (levelIdx, var level) in tree.enumerated().reversed() {
            for (groupIdx, var siblingGroup) in level.enumerated() {
                for (siblingIdx, var sibling) in siblingGroup.siblings.enumerated() {
                    sibling.fractPos = Position(x: Double(x), y: Double(y))
                    siblingGroup.siblings[siblingIdx] = sibling
                    x += m.nodeSpacingX + m.nodeSize.width
                }

                x += m.interSiblingsSpacing + m.nodeSize.width

                level[groupIdx] = siblingGroup
            }

            y -= (m.nodeSize.height + m.rowSpacing)
            x = left
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

    static func tree(from nodes: [Node]) -> [[LayoutNodeSiblings]] {
        func findChildren(node: Node) -> LayoutNodeSiblings {
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
            let nextRootNodes = siblings
                .flatMap { $0.siblings
                    .filter { node in !node.childNodeIds.isEmpty } // only include non-leaf nodes as next root node
                }
            rootNodes = nextRootNodes
        }

        return rootNodeSiblings
    }
}
