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

    var boxNode: GIRNode!
    var boxNode1: GIRNode!
    var blubNode: GIRNode!
    override func viewDidLoad() {
        super.viewDidLoad()

//        let box = GIRCube()
//        box.addMaterial(name: "cube")
//        boxNode = GIRNode(geometry: box)
//        boxNode1 = GIRNode(geometry: box)
        let blub = GIRGeometry(name: "blub", ext: "obj")
        blub.addMaterial(name: "blub_baseColor")
        blubNode = GIRNode(geometry: blub)
        let scene = GIRScene()
        scene.rootNode.addChild(blubNode)
//        scene.rootNode.addChild(boxNode)
//        scene.rootNode.addChild(boxNode1)
//        boxNode1.translation = float3(0, -2, 0)

        giraffeView.scene = scene
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let curr = touch.location(in: view)
        let prev = touch.previousLocation(in: view)
        let diff = CGPoint(x: curr.x - prev.x, y: curr.y - prev.y)

        blubNode.rotation = float4(1, 0, 0, Float(diff.y).radian)
        blubNode.rotation = float4(0, 1, 0, Float(diff.x).radian)

//        boxNode.translation = float3(Float(diff.x) / 100, Float(diff.y) / 100, 0)
    }
}

extension Float {
    var radian: Float {
        return self * .pi / 180
    }
}
