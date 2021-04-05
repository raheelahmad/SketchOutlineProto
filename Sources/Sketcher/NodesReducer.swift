import NodeView

final class NodesReducer {
    static func update(canvas: CanvasUIView, with nodes: [Node]) {
        let updatedViews = views(for: nodes, previousViews: canvas.nodes)
    }

    static func views(for nodes: [Node], previousViews: [NodeUIView]) -> [NodeUIView] {
        []
    }
}
