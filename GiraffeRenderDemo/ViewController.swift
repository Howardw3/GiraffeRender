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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = GIRScene()
        createCube()
        createFish()
        
//        scene.rootNode.addChild(fishNode)
        scene.rootNode.addChild(cubeNode)
        currNode = cubeNode
        giraffeView.scene = scene
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let curr = touch.location(in: view)
        let prev = touch.previousLocation(in: view)
        let diff = CGPoint(x: curr.x - prev.x, y: curr.y - prev.y)

        currNode.rotation = float4(1, 0, 0, Float(diff.y).radian)
        currNode.rotation = float4(0, 1, 0, Float(diff.x).radian)

//        boxNode.translation = float3(Float(diff.x) / 100, Float(diff.y) / 100, 0)
    }
    
    func createFish() {
        let fish = GIRGeometry(name: "fish", ext: "obj")
        fish.addMaterial(name: "fish_baseColor")
        fishNode = GIRNode(geometry: fish)
    }
    
    func createCube() {
        let cube = GIRGeometry(name: "cube", ext: "obj")
        cube.addMaterial(name: "fish_baseColor")
        cubeNode = GIRNode(geometry: cube)
        
//        if let material = cube.materials.first {
//            material.ambient = float3(1, 1, 1)
//            material.
//        }
    }
}

extension Float {
    var radian: Float {
        return self * .pi / 180
    }
}
