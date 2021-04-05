struct Position: Codable {
    let x: Double
    let y: Double
}

struct Node: Codable {
    let id: String
    var title: String?
    let colorHex: String
    var fractPos: Position
    var linkedNodeIds: Set<String>
}
