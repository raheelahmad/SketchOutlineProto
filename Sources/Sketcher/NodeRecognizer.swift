//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 4/3/21.
//

import UIKit

final class NodeRecognizer: UIGestureRecognizer {
    private(set) var line: Line?
    private var trackedTouch: UITouch?

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
            line = Line(id: UUID().uuidString, points: [location])
            self.trackedTouch = trackedTouch
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, touch == trackedTouch else {
            state = .failed
            return
        }
        let location = self.location(in: view)
        guard isPointValid(location) else {
            state = .failed
            return
        }
        line?.points.append(location)
        /// TODO: can inspect line's points (similar to boundingRect) to
        /// check if it has failed already.
        /// E.g., if it has moved in the wrong angles (e.g., making an angle more than 180 deg)
        state = .changed
    }

    private func isPointValid(_ point: CGPoint) -> Bool {
        for subView in (self.view?.subviews ?? []) {
            let pointInSubview = subView.convert(point, from: self.view)
            // should not overlap any subview
            if subView.bounds.contains(pointInSubview) {
                return false
            }
        }

        return true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first, touch == trackedTouch else {
            state = .failed
            return
        }

        line?.resample(atLength: 20)
        line?.calculateAngles()
        if line?.boundingRect != nil {
            state = .recognized
        } else {
            state = .failed
        }
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
}
