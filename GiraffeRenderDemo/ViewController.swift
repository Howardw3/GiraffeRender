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
//        float3( 2.0,  -2.0, -4.0),
//        float3(-1.5, -2.2, -6.5),
//        float3(0.8, -2.0, -4.3),
//        float3( 2.4, -2.4, -4.5),
        float3( 0.0, 2.0, 0.0)
    ]
    var cameraPos = float3()

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
//        scene.rootNode.addChild(sphereNode)

        giraffeView.scene = scene
        scene.pointOfView.position = float3(0, 0, -10)
        scene.pointOfView.camera?.fieldOfView = 29
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(recognizePinch(pinch:)))
        giraffeView.addGestureRecognizer(pinchGesture)
    }

    @objc
    func recognizePinch(pinch: UIPinchGestureRecognizer) {
        cameraPos.z = 1 - Float(pinch.scale)
        scene.pointOfView.position = cameraPos
        print(scene.pointOfView.position)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let curr = touch.location(in: view)
        let prev = touch.previousLocation(in: view)
        let diff = CGPoint(x: curr.x - prev.x, y: curr.y - prev.y)

        currNode.eularAngles = float3(Float(diff.y), Float(diff.x), 0)
        print(currNode.position)
//        currNode.rotation = float4(1, 0, 0, Float(diff.y).radian)
//        currNode.rotation = float4(0, 1, 0, Float(diff.x).radian)

//        boxNode.translation = float3(Float(diff.x) / 100, Float(diff.y) / 100, 0)
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
            cubeNode.eularAngles = float3(Float(i * 20), 0, 0)
            scene.rootNode.addChild(cubeNode)
        }
    }
}

extension Float {
    var radian: Float {
        return self * .pi / 180
    }
}
