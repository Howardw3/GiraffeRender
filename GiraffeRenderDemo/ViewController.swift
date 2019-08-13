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
    override func viewDidLoad() {
        super.viewDidLoad()

        let fish = GIRGeometry(name: "fish", ext: "obj")
        fish.addMaterial(name: "fish_baseColor")
        fishNode = GIRNode(geometry: fish)
        let scene = GIRScene()
        scene.rootNode.addChild(fishNode)

        giraffeView.scene = scene
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let curr = touch.location(in: view)
        let prev = touch.previousLocation(in: view)
        let diff = CGPoint(x: curr.x - prev.x, y: curr.y - prev.y)

        fishNode.rotation = float4(1, 0, 0, Float(diff.y).radian)
        fishNode.rotation = float4(0, 1, 0, Float(diff.x).radian)

//        boxNode.translation = float3(Float(diff.x) / 100, Float(diff.y) / 100, 0)
    }
}

extension Float {
    var radian: Float {
        return self * .pi / 180
    }
}
