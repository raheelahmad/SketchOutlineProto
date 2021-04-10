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

class NodesAutoLayout {
    struct Metrics {
        let nodeSize: CGSize
        let nodeSpacingX: CGFloat
        let nodeSpacingY: CGFloat

        let interSiblingsSpacing: CGFloat

        let rowSpacing: CGFloat

    }
    static func layout(nodes: [LayoutNode])
}
