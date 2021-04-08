//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 4/3/21.
//

import UIKit
import NodeView

final class LinkRecognizer: UIGestureRecognizer {
    private(set) var line: Line?
    private var trackedTouch: UITouch?

    /// This will exist if there is a valid gesture
    private(set) var initialSubview: NodeUIView?
    /// This may not exist
    private(set) var finalSubview: NodeUIView?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        guard touches.count == 1 else {
            self.state = .failed
            return
        }

        if let trackedTouch = self.trackedTouch {
            // ignore subsequent single touches
            for touch in touches {
                if touch != trackedTouch {
                    ignore(touch, for: event)
                }
            }
        } else {
            let trackedTouch = touches.first!
            let location = trackedTouch.location(in: view)
            guard let initialSubview = subView(at: location) else {
                state = .failed
                return
            }

            line = Line(id: UUID().uuidString, points: [location])
            self.trackedTouch = trackedTouch
            self.initialSubview = initialSubview
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, touch == trackedTouch else {
            state = .failed
            return
        }
        let location = self.location(in: view)
        line?.points.append(location)

        if state != .changed, isLineValid {
            state = .began
        } else {
            state = .changed
        }
    }

    private func isInitialPointValid(_ point: CGPoint) -> Bool {
        return subView(at: point) != nil
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first, touch == trackedTouch else {
            state = .failed
            return
        }
        guard isLineValid else {
            state = .failed
            return
        }

        let location = self.location(in: view)
        finalSubview = subView(at: location)
        state = .ended
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        _reset()
    }

    override func reset() {
        super.reset()
        _reset()
    }

    private func _reset() {
        trackedTouch = nil
        line = nil
    }

    private var isLineValid: Bool {
        if let length = line?.length, length > 10 {
            return true
        } else {
            return false
        }
    }
}

extension UIGestureRecognizer {
    func subView(at point: CGPoint) -> NodeUIView? {
        let subViews = (self.view?.subviews ?? []).compactMap { $0 as? NodeUIView }
        for subView in subViews {
            let pointInSubview = subView.convert(point, from: self.view)
            // should not overlap any subview
            if subView.bounds.contains(pointInSubview) {
                return subView
            }
        }

        return nil
    }

}
