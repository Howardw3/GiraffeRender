//
//  ViewController.swift
//  GiraffeRenderDemo
//
//  Created by Howard Wang on 8/11/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import UIKit
import GiraffeRender
import simd
//import GLKit
//import SceneKit

class ViewController: UIViewController {
    enum GestureControl {
        case camera
        case light
        case object
    }

    @IBOutlet weak var giraffeView: GIRView!
    @IBOutlet weak var objectButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var lightButton: UIButton!

    var fishNode: GIRNode!
    var cubeNode: GIRNode!
    var currNode: GIRNode!
    var currCameraNode: GIRNode!
    var currLightNode: GIRNode!
    var sphereNode: GIRNode!
    var scene: GIRScene!
    let cubePositions: [float3] = [
        float3( 2.0, -2.0, -4.0),
        float3(-1.5, -2.2, -6.5),
        float3(0.8, 2.0, -4.3),
        float3(2.8, 1.0, -7.3),
        float3( 2.4, -2.4, -4.5),
        float3( 2.0, 1.0, 0.0)
    ]
    var cameraPos = float3(0, 0, -10)
    var currGestureControl: GestureControl = .object
    let feedbackGenerator = UIImpactFeedbackGenerator()
    var prevPos = CGPoint.zero
    override func viewDidLoad() {
        super.viewDidLoad()

        scene = GIRScene()
        currLightNode = createLightNode()
        scene.rootNode.addChild(currLightNode)
        createCubes()
        currNode = cubeNode

        currCameraNode = scene.pointOfView
        giraffeView.scene = scene
        scene.pointOfView.position = cameraPos
        scene.pointOfView.camera?.fieldOfView = 29

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
                if recognizer.numberOfTouches == 1 { // disable now
    //                currCameraNode.pivot = float3(0, 0, 0)
                    currCameraNode.eularAngles += float3(Float(diff.y), Float(diff.x), 0)
                } else if recognizer.numberOfTouches == 2 {
                    currCameraNode.position += float3(Float(diff.x) / 100, Float(diff.y) * -1 / 100, 0)
                }
            case .light:
                if recognizer.numberOfTouches == 1 { // disable now
                    currLightNode.eularAngles += float3(Float(diff.y), Float(diff.x), 0)
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
        case .light:
            currLightNode.position.z += scale
        case .object:
            currNode.position.z += scale
        }
    }
    
    @objc func recognizeLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let touch = recognizer.location(in: recognizer.view)
    }
    
    @objc func recognizeDoubleTap() {

    }

    func createFish() -> GIRNode {
        let fish = GIRGeometry(name: "fish/fish", ext: "obj")
        fish.addMaterial(name: "fish_alb")
        return GIRNode(geometry: fish)
    }

    func createTexturedCube() -> GIRNode {
        let cube = GIRGeometry(name: "textured_cube/textured_cube", ext: "obj")
        cube.addMaterial(name: "textured_cube_alb")
        return GIRNode(geometry: cube)

//        if let material = cube.materials.first {
//            material.ambient = float3(1, 1, 1)
//            material.
//        }
    }

    func createCube() -> GIRNode {
        let cube = GIRGeometry(name: "cube/cube", ext: "obj")
        cube.addMaterial(name: "cube_alb")
        return GIRNode(geometry: cube)
    }
    
    func createCone() -> GIRNode {
        let cone = GIRGeometry(name: "BasicGeo/cone", ext: "obj")
        cone.addMaterial(name: "cube_alb")
        return GIRNode(geometry: cone)
    }
    
    func createLightNode() -> GIRNode {
        let light = GIRLight(type: .spot)
        light.color = UIColor.red.cgColor
        let lightNode = createCone()
        lightNode.position = float3(2.0, 0.0, 2.0)
        lightNode.scale = 0.2
        lightNode.light = light
        return lightNode
    }

    func createCubes() {
        for i in 0..<cubePositions.count {
            cubeNode = createTexturedCube()
            cubeNode.position = cubePositions[i]
            cubeNode.scale = 1.0
            cubeNode.eularAngles = float3(1, 1, 1) * Float(i * 20)
            scene.rootNode.addChild(cubeNode)
        }
    }

    @IBAction func didTapObjectButton(_ sender: UIButton) {
        currGestureControl = .object
        feedbackGenerator.impactOccurred()
        sender.backgroundColor = .white
        cameraButton.backgroundColor = .clear
        lightButton.backgroundColor = .clear
    }

    @IBAction func didTapCameraButton(_ sender: UIButton) {
        currGestureControl = .camera
        feedbackGenerator.impactOccurred()
        sender.backgroundColor = .white
        objectButton.backgroundColor = .clear
        lightButton.backgroundColor = .clear
    }

    @IBAction func didTapLightButton(_ sender: UIButton) {
        currGestureControl = .light
        feedbackGenerator.impactOccurred()
        sender.backgroundColor = .white
        cameraButton.backgroundColor = .clear
        objectButton.backgroundColor = .clear
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith: UIGestureRecognizer) -> Bool {
        return true
    }
}
