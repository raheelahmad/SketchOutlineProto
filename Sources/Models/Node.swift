
public struct Position: Codable {
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public let x: Double
    public let y: Double
}

public struct Node: Codable {
    public init(id: String, title: String? = nil, colorHex: String, fractPos: Position, linkedNodeIds: Set<String>) {
        self.id = id
        self.title = title
        self.colorHex = colorHex
        self.fractPos = fractPos
        self.linkedNodeIds = linkedNodeIds
    }

    public let id: String
    public var title: String?
    public let colorHex: String
    public var fractPos: Position
    public var linkedNodeIds: Set<String>
}
