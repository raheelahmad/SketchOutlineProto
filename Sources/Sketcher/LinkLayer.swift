import UIKit

struct NodeRecognition {
    let center: CGPoint
}

enum LinkRecognition {
    case onlyFrom(fromNodeId: String, to: CGPoint)
    case fromTo(fromNodeId: String, toNodeId: String)
}


final class LinkLayer: CAShapeLayer {
    let fromId: String
    let toId: String

    init(fromId: String, toId: String) {
        self.fromId = fromId
        self.toId = toId

        super.init()

        self.strokeColor = UIColor.hex(0xB2B7BB).cgColor
        self.lineWidth = 3
        self.fillColor = UIColor.clear.cgColor
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

