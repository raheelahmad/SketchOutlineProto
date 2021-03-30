//
//  File.swift
//  
//
//  Created by Raheel Ahmad on 3/29/21.
//

import UIKit

extension Sketcher {
    func setupDebugUI() {
        guard showsDebug else {
            return
        }

        tangentSlider.minimumValue = 0
        tangentSlider.addTarget(self, action: #selector(tangentSliderMoved), for: .valueChanged)
        tangentSlider.addTarget(self, action: #selector(tangentSliderEnded), for: .touchUpInside)
        tangentSlider.addTarget(self, action: #selector(tangentSliderEnded), for: .touchUpOutside)
        tangentSlider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tangentSlider)
        NSLayoutConstraint.activate([
            tangentSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tangentSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20)
        ])
        angleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(angleLabel)
        NSLayoutConstraint.activate([
            angleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            angleLabel.topAnchor.constraint(equalTo: tangentSlider.bottomAnchor, constant: 20)
        ])
    }

    @objc
    func tangentSliderMoved() {
        let index = Int(tangentSlider.value)
        tangentSliderIndex = index
    }

    @objc
    private func tangentSliderEnded() {
        tangentSliderIndex = nil
        tangentSlider.value = 0
    }

    func updateAngle() {
        guard let index = tangentSliderIndex else {
            return
        }
        guard let angle = currentLine.angles.first(where: { $0.index == index }) else { return }
        angleLabel.text = String(format: "%.2f", angle.angle)
        if angle.isMajorTurn {
            print(String(format: "MAJOR turn at %.2f (%.2f) [%d]", angle.angle, angle.normalized, angle.index))
        } else if angle.isMinorTurn {
            print(String(format: "minor turn at %.2f (%.2f) [%d]", angle.angle, angle.normalized, angle.index))
        } else {
            print(String(format: "%.2f (%.2f | %.2f → %.2f) [%d]", angle.angle, angle.normalized, angle.minorThreshold, angle.majorThreshold, angle.index))
        }
    }

}
