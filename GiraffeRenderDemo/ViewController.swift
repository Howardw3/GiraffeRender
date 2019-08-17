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

    @IBOutlet weak var giraffeView: GIRView!

    var fishNode: GIRNode!
    var cubeNode: GIRNode!
    var currNode: GIRNode!
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
    var currNodePos = float3()

    override func viewDidLoad() {
        super.viewDidLoad()

        scene = GIRScene()
        createCubes()
//        createCube()
//        createFish()
//        createSphere()
//        scene.rootNode.addChild(fishNode)
//        currNode = fishNode

        currNode = cubeNode
        currNodePos = currNode.position
//        scene.rootNode.addChild(sphereNode)

        giraffeView.scene = scene
        scene.pointOfView.position = cameraPos
        scene.pointOfView.camera?.fieldOfView = 29
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(recognizePinch(_:)))
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(recognizePan(_:)))
//        giraffeView.addGestureRecognizer(pinchGesture)
//        giraffeView.addGestureRecognizer(panGesture)
        self.giraffeView.isMultipleTouchEnabled = true
    }

    @objc
    func recognizePinch(_ recognizer: UIPinchGestureRecognizer) {
        cameraPos.z += 1 - Float(recognizer.scale)
        scene.pointOfView.position = cameraPos
    }

//    @objc func recognizePan(_ recognizer: UIPanGestureRecognizer) {
//        if recognizer.numberOfTouches == 1 {
//            let curr = recognizer.translation(in: self.view)
//            let velocity = recognizer.velocity(in: self.view)
//            print(curr, velocity)
//            currNode.eularAngles += float3(Float(curr.y / velocity.x), Float(curr.x / velocity.y), 0)
//        }
//    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let curr = touch.location(in: view)
        let prev = touch.previousLocation(in: view)
        let diff = CGPoint(x: curr.x - prev.x, y: curr.y - prev.y)
        if touches.count == 1 {
            currNode.eularAngles += float3(Float(diff.y), Float(diff.x), 0)
        } else {
            currNode.position += float3(Float(diff.x) / 100, Float(diff.y) * -1 / 100, 0)
        }
    }

    func createFish() -> GIRNode {
        let fish = GIRGeometry(name: "fish/fish", ext: "obj")
        fish.addMaterial(name: "fish_alb")
        return GIRNode(geometry: fish)
    }

    func createCube() -> GIRNode {
        let cube = GIRGeometry(name: "cube/RubixCube", ext: "obj")
        cube.addMaterial(name: "Diffuse_Normal")
        return GIRNode(geometry: cube)

//        if let material = cube.materials.first {
//            material.ambient = float3(1, 1, 1)
//            material.
//        }
    }

    func createCubes() {
        for i in 0..<cubePositions.count {
            cubeNode = createFish()
            cubeNode.position = cubePositions[i]
            cubeNode.eularAngles = float3(1, 1, 1) * Float(i * 20)
            scene.rootNode.addChild(cubeNode)
        }
    }
}
