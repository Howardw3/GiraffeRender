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
    var cameraPos = float3(0, 0, 20)
    var currGestureControl: GestureControl = .object
    let feedbackGenerator = UIImpactFeedbackGenerator()
    var prevPos = CGPoint.zero
    override func viewDidLoad() {
        super.viewDidLoad()

        scene = GIRScene()
        currLightNode = createLightNode()
        scene.rootNode.addChild(currLightNode)
        createCubes()
        let floorNode = createPlaneNode()
        floorNode.eularAngles.x = 90.0
        floorNode.position = float3(0, -3, 0)
        floorNode.scale = 5.0
        scene.rootNode.addChild(floorNode)
        currNode = cubeNode

        currCameraNode = scene.pointOfView
        giraffeView.scene = scene
        scene.pointOfView.position = cameraPos
        scene.pointOfView.camera?.fieldOfView = 29

        setupGestrues()
    }

    func createFish() -> GIRNode {
        let fish = GIRGeometry(name: "fish/fish", ext: "obj")
        let material = GIRMaterial()
        material.albedo.content = "fish_alb"
        fish.material = material
        return GIRNode(geometry: fish)
    }

    func createTexturedCube() -> GIRNode {
        let cube = GIRGeometry(name: "Art.scnassets/textured_cube/textured_cube", ext: "obj")
        let material = GIRMaterial()
        material.albedo.content = "textured_cube_alb"
//        material.specular.content = "textured_cube_specular"
        material.normal.content = "textured_cube_normal"
        material.shininess = 1.0
        cube.material = material
        return GIRNode(geometry: cube)

//        if let material = cube.materials.first {
//            material.ambient = float3(1, 1, 1)
//            material.
//        }
    }

    func createCube() -> GIRNode {
        let cube = GIRGeometry(basic: .box(size: float3(1, 1, 1), segments: [1, 1, 1]))
        let material = GIRMaterial()
        material.albedo.content = "cube_alb"
        cube.material = material
        return GIRNode(geometry: cube)
    }
    
    func createCone() -> GIRNode {
        let cone = GIRGeometry(basic: .cone(size: float3(2, 5, 2), segments: [3, 3], cap: false))
        let material = GIRMaterial()
        material.albedo.content = "cube_alb"
        cone.material = material
        return GIRNode(geometry: cone)
    }
    
    func createLightNode() -> GIRNode {
        let light = GIRLight(type: .spot)
        light.intensity = 4.0
//        light.color = UIColor.white.cgColor
        light.color = UIColor(red: 238/255, green: 220/255, blue: 165/255, alpha: 1.0).cgColor
        let lightNode = createCone()
        lightNode.position = float3(0.0, 0.0, 3.0)
        lightNode.scale = 0.2
        lightNode.light = light
        return lightNode
    }

    func createPlaneNode() -> GIRNode {
        let plane = GIRGeometry(basic: .plane(size: float3(4, 4, 1), segments: [1, 1]))
        let material = GIRMaterial()
        material.albedo.content = "brickwall_diffuse"
        material.normal.content = "brickwall_normal"
        plane.material = material
        return GIRNode(geometry: plane)
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
                    currLightNode.debugPrintLocalAxis()
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
        //            print(currCameraNode.position)
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

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith: UIGestureRecognizer) -> Bool {
        return true
    }
}
