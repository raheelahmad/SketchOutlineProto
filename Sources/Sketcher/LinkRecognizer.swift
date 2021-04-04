//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 4/3/21.
//

import UIKit

final class LinkRecognizer: UIGestureRecognizer {
    private(set) var line: Line?
    private var trackedTouch: UITouch?

    /// This will exist if there is a valid gesture
    private(set) var initialSubview: UIView?
    /// This may not exist
    private(set) var finalSubview: UIView?

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

            state = .began

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
        /// TODO: can inspect line's points (similar to boundingRect) to
        /// check if it has failed already.
        /// E.g., if it has moved in the wrong angles (e.g., making an angle more than 180 deg)
        state = .changed
    }

    private func isInitialPointValid(_ point: CGPoint) -> Bool {
        return subView(at: point) != nil
    }

    // TODO: could be an extension of GR
    private func subView(at point: CGPoint) -> UIView? {
        // TODO: use map
        for subView in (self.view?.subviews ?? []) {
            let pointInSubview = subView.convert(point, from: self.view)
            // should not overlap any subview
            if subView.bounds.contains(pointInSubview) {
                return subView
            }
        }

        return nil
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first, touch == trackedTouch else {
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
}
