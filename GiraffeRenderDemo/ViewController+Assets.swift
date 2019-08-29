//
//  ViewController+Assets.swift
//  GiraffeRenderDemo
//
//  Created by Jiongzhi Wang on 8/28/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import GiraffeRender
import simd

extension ViewController {
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
        material.albedo.content = UIImage(named: "Art.scnassets/textured_cube/textured_cube_alb.png")
        material.specular.content = UIImage(named: "Art.scnassets/textured_cube/textured_cube_specular.png")
        material.normal.content = UIImage(named: "Art.scnassets/textured_cube/textured_cube_normal.png")

        material.shininess = 1.0
        cube.material = material
        return GIRNode(geometry: cube)
    }

    func createCube() -> GIRNode {
        let cube = GIRGeometry(basic: .box(size: float3(1, 1, 1), segments: [10, 10, 10]))
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

    func createSuitcase() -> GIRNode {
        let geo = GIRGeometry(name: "Art.scnassets/cyborg/cyborg", ext: "obj")
        let material = GIRMaterial()
        material.diffuse.content = UIImage(named: "Art.scnassets/cyborg/cyborg_diffuse.png")
        material.specular.content = UIImage(named: "Art.scnassets/cyborg/cyborg_specular.png")
        material.normal.content = UIImage(named: "Art.scnassets/cyborg/cyborg_normal.png")
        geo.material = material
        return GIRNode(geometry: geo)
    }

    func createCubes() {
        for i in 0..<cubePositions.count {
            cubeNode = createTexturedCube()
            //            cubeNode = createCube()
            cubeNode.position = cubePositions[i]
            cubeNode.scale = 1.0
            cubeNode.eularAngles = float3(1, 1, 1) * Float(i * 20)
            scene.rootNode.addChild(cubeNode)
        }
    }
}
