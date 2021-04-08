import UIKit
import NodeView

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
        self.lineWidth = 2
        self.fillColor = UIColor.clear.cgColor
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension LinkLayer {
    func updateLinkPath(from: NodeUIView, to: NodeUIView) {
        let p = UIBezierPath()

        let (fromP, toP) = CGRect.linkPoints(from: from.frame, to: to.frame)
        p.move(to: fromP)
        let (m1, m2) = CGPoint.controlPoints(between: fromP, and: toP)
        p.addCurve(to: toP, controlPoint1: m1, controlPoint2: m2)
        let size: CGFloat = 8
        let ellipse = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: toP.x - size/2, y: toP.y - size/2), size: .init(width: size, height: size)))
        let ellipseLayer = CAShapeLayer()
        ellipseLayer.path = ellipse.cgPath
        ellipseLayer.strokeColor = UIColor.clear.cgColor
        ellipseLayer.fillColor = UIColor.red.cgColor
        addSublayer(ellipseLayer)
        self.path = p.cgPath
    }
}
