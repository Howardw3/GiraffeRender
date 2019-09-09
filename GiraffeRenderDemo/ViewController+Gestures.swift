//
//  ViewController+Gestures.swift
//  GiraffeRenderDemo
//
//  Created by Jiongzhi Wang on 8/28/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import UIKit
import simd

extension ViewController: UIGestureRecognizerDelegate {
    func setupGestrues() {
        didTapCameraButton(UIButton())
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(recognizePinch(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(recognizePan(_:)))
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(recognizeDoubleTap))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recognizeLongPress(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        giraffeView.addGestureRecognizer(doubleTapGesture)
        giraffeView.addGestureRecognizer(pinchGesture)
        giraffeView.addGestureRecognizer(panGesture)
        giraffeView.addGestureRecognizer(longPressGesture)
        self.giraffeView.isMultipleTouchEnabled = true
    }

    @objc func recognizePan(_ recognizer: UIPanGestureRecognizer) {
        let curr = recognizer.translation(in: self.view)
        let diff = CGPoint(x: curr.x - prevPos.x, y: curr.y - prevPos.y)
        prevPos = curr
        if recognizer.state == .began {

        } else if recognizer.state == .changed {

            switch currGestureControl {
            case .camera:
                if recognizer.numberOfTouches == 1 {
                    //                currCameraNode.pivot = float3(0, 0, 0)
                    currCameraNode.eularAngles += float3(Float(diff.y), Float(diff.x), 0)
                } else if recognizer.numberOfTouches == 2 {
                    currCameraNode.position += float3(Float(diff.x) / 100, Float(diff.y) * -1 / 100, 0)
                }
            case .light:
                if recognizer.numberOfTouches == 1 {
                    currLightNode.eularAngles += float3(Float(diff.y), Float(diff.x), 0)
                    //                    currLightNode.debugPrintLocalAxis()
                } else if recognizer.numberOfTouches == 2 {
                    currLightNode.position += float3(Float(diff.x) / 100, Float(diff.y) * -1 / 100, 0)
                }
            case .object:
                if recognizer.numberOfTouches == 1 {
                    currNode.eularAngles += float3(Float(diff.y), Float(diff.x), 0)
                } else if recognizer.numberOfTouches == 2 {
                    currNode.position += float3(Float(diff.x) / 100, Float(diff.y) * -1 / 100, 0)
                }
            }
        }
    }

    @objc func recognizePinch(_ recognizer: UIPinchGestureRecognizer) {
        let scale = Float(recognizer.scale) - 1
        switch currGestureControl {
        case .camera:
            currCameraNode.position.z += scale
//                    print(currCameraNode.position)
        case .light:
            currLightNode.position.z += scale
//            print(currLightNode.position.z)
        case .object:
            currNode.position.z += scale
        }
    }

    @objc func recognizeLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let touch = recognizer.location(in: recognizer.view)
    }

    @objc func recognizeDoubleTap() {

    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith: UIGestureRecognizer) -> Bool {
        return true
    }
}
