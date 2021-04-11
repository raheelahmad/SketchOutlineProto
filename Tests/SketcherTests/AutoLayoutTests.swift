import XCTest
import Models
@testable import Sketcher

extension Position {
    static var zero: Position { .init(x: 0, y: 0) }
}

final class AutoLayoutTests: XCTestCase {
    func testAutoLayout() {
        XCTAssertEqual(2, 2)
    }


    func testTreeStructure() {
        struct AssertProps {
            let parentId: String?
            let siblingIds: Set<String>
        }

        func assert(props: [AssertProps], forRow row: Int, rowSiblings: [LayoutNodeSiblings]) {
            XCTAssertEqual(rowSiblings.count, props.count, "Should have correct number of sibling groups in row \(row)")
            for (idx, prop) in props.enumerated() {
                let siblings = rowSiblings[idx]
                XCTAssertEqual(siblings.parentId, prop.parentId, "Should have correct parentId for row \(row)")
                XCTAssertEqual(siblings.siblings.count, prop.siblingIds.count, "Should have correct number of siblings")
                let ids = siblings.siblings.map { $0.id }
                for expectedId in prop.siblingIds {
                    XCTAssert(ids.contains(expectedId), "Should have the expected sibling")
                }
            }
        }

        let nodesTree = NodesAutoLayout.tree(from: nodes())
        XCTAssertEqual(nodesTree.count, 4)

        let firstRow = nodesTree[0]
        assert(props: [.init(parentId: nil, siblingIds: ["a"])], forRow: 0, rowSiblings: firstRow)

        let secondRow = nodesTree[1]
        assert(
            props: [
                .init(parentId: "a", siblingIds: ["b", "c"]),
            ],
            forRow: 1,
            rowSiblings: secondRow
        )

        let thirdRow = nodesTree[2]
        assert(
            props: [
                .init(parentId: "b", siblingIds: ["d"]),
                .init(parentId: "c", siblingIds: ["e", "f"]),
            ],
            forRow: 2,
            rowSiblings: thirdRow
        )

        let fourthRow = nodesTree[3]
        assert(
            props: [
                .init(parentId: "d", siblingIds: ["g", "h", "i"]),
                .init(parentId: "e", siblingIds: ["j", "k"]),
                .init(parentId: "f", siblingIds: ["l", "m"]),
            ],
            forRow: 3,
            rowSiblings: fourthRow
        )
    }

    func testLayout() {
        var nodes: [LayoutNode] = self.nodes()
        NodesAutoLayout.layout(
            nodes: &nodes,
            m: NodesAutoLayout.Metrics(
                nodeSize: .init(width: 0.1, height: 0.02),
                nodeSpacingX: 0.02,
                nodeSpacingY: 0.05,
                interSiblingsSpacing: 0.04,
                rowSpacing: 0.1
            )
        )
        for node in nodes {
            print(node.fractPos)
        }
    }

    extension Node {
        init(id: String, childNodesIds: )
    }

    private func nodes() -> [Node] {
        [
            Node(id: "a", childNodeIds: ["b", "c"], fractPos: .zero),
            Node(id: "b", childNodeIds: ["d",], fractPos: .zero),
            Node(id: "c", childNodeIds: ["e", "f"], fractPos: .zero),
            Node(id: "d", childNodeIds: ["g", "h", "i"], fractPos: .zero),
            Node(id: "e", childNodeIds: ["j", "k", ], fractPos: .zero),
            Node(id: "f", childNodeIds: ["l", "m", ], fractPos: .zero),
            Node(id: "g", childNodeIds: [], fractPos: .zero),
            Node(id: "h", childNodeIds: [], fractPos: .zero),
            Node(id: "i", childNodeIds: [], fractPos: .zero),
            Node(id: "j", childNodeIds: [], fractPos: .zero),
            Node(id: "k", childNodeIds: [], fractPos: .zero),
            Node(id: "l", childNodeIds: [], fractPos: .zero),
            Node(id: "m", childNodeIds: [], fractPos: .zero),
        ]
    }

    static var allTests = [
        ("testAutoLayout", testAutoLayout),
    ]
}
