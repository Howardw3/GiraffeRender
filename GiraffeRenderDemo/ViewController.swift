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
        float3( 2.0, 5.0, -9.7),
        float3(-1.5, -4.2, -6.5),
//        float3(0.8, 2.0, -4.3),
        float3(-1.0, 0.0, 0),
//        float3( 2.4, -2.4, -4.5),
        float3( 2.0, 1.0, 0.0)
    ]
    var cameraPos = float3(0, 0, 50)
    var currGestureControl: GestureControl = .object
    let feedbackGenerator = UIImpactFeedbackGenerator()
    var prevPos = CGPoint.zero
    override func viewDidLoad() {
        super.viewDidLoad()

        scene = GIRScene()
        scene.background.content = [
            getArtResourcesPath(folder: "skybox", name: "right", ext: "jpg"),
            getArtResourcesPath(folder: "skybox", name: "left", ext: "jpg"),
            getArtResourcesPath(folder: "skybox", name: "top", ext: "jpg"),
            getArtResourcesPath(folder: "skybox", name: "bottom", ext: "jpg"),
            getArtResourcesPath(folder: "skybox", name: "front", ext: "jpg"),
            getArtResourcesPath(folder: "skybox", name: "back", ext: "jpg")
        ]

        currLightNode = createLightNode()
        scene.rootNode.addChild(currLightNode)
//        createCubes()
        let sphereNode = createSphere()
        sphereNode.geometry?.material = createRustedIronMaterial()
        scene.rootNode.addChild(sphereNode)

        currNode = sphereNode

        currCameraNode = scene.pointOfView
        giraffeView.scene = scene
        scene.pointOfView.position = cameraPos
        scene.pointOfView.camera?.fieldOfView = 29

        setupGestrues()
    }

    func createLightNode() -> GIRNode {
        let light = GIRLight(type: .omni)
        light.intensity = 100
        light.color = UIColor.white.cgColor
//        light.color = UIColor(red: 238/255, green: 220/255, blue: 165/255, alpha: 1.0).cgColor
        let lightNode = createCone()
        lightNode.position = float3(0.0, 0.0, 11.0)
        lightNode.scale = 0.1
        lightNode.light = light
        return lightNode
    }

    func addFloorNode() {
        let floorNode = createPlaneNode()
        floorNode.eularAngles.y = 180.0
        floorNode.eularAngles.z = 180.0
        floorNode.position = float3(0, 0, -10)
        floorNode.scale = 10.0
        scene.rootNode.addChild(floorNode)
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
