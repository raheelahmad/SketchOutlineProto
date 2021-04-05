struct Position {
    let x: Double
    let y: Double
}
struct Node {
    let id: String
    let title: String
    let colorHex: String
    var fractPos: Position
    var linkedNodeIds: Set<String>
}

