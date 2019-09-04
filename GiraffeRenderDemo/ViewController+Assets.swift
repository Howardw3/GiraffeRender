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
        let cube = GIRGeometry(basic: .box(size: float3(1, 1, 1), segments: [10, 10, 10], inward: false))
        let material = GIRMaterial()
        material.albedo.content = "cube_alb"
        cube.material = material
        return GIRNode(geometry: cube)
    }

    func createCone() -> GIRNode {
        let cone = GIRGeometry(basic: .cone(size: float3(2, 5, 2), segments: [1, 1], cap: false))
        let material = GIRMaterial()
        material.albedo.content = "cube_alb"
//        cone.material = material
        return GIRNode(geometry: cone)
    }

    func createAvatar() -> GIRNode {
        let geo = GIRGeometry(name: "Art.scnassets/cyborg/cyborg", ext: "obj")
        let material = GIRMaterial()
        material.diffuse.content = UIImage(named: "Art.scnassets/cyborg/cyborg_diffuse.png")
        material.specular.content = UIImage(named: "Art.scnassets/cyborg/cyborg_specular.png")
        material.normal.content = UIImage(named: "Art.scnassets/cyborg/cyborg_normal.png")
        geo.material = material
        return GIRNode(geometry: geo)
    }

    func createPlaneNode() -> GIRNode {
        let plane = GIRGeometry(basic: .plane(size: float3(4, 4, 1), segments: [1, 1]))
        let material = GIRMaterial()
        material.albedo.content = "brickwall_diffuse"
        material.normal.content = "brickwall_normal"
        plane.material = material
        return GIRNode(geometry: plane)
    }

    func createRustedIronMaterial() -> GIRMaterial {
        let material = GIRMaterial()
        let folder = "rusted_iron"
        material.albedo.content = UIImage(named: getArtResourcesPath(folder: folder, name: "albedo"))
        material.ambientOcclusion.content = UIImage(named: getArtResourcesPath(folder: folder, name: "ao"))
        material.metalness.content = UIImage(named: getArtResourcesPath(folder: folder, name: "metallic"))
        material.normal.content = UIImage(named: getArtResourcesPath(folder: folder, name: "normal"))
        material.roughness.content = UIImage(named: getArtResourcesPath(folder: folder, name: "roughness"))

        return material
    }

    func createTestMaterial() -> GIRMaterial {
        let material = GIRMaterial()
        let folder = "test"
        material.albedo.content = UIImage(named: getArtResourcesPath(folder: folder, name: "Titanium-Scuffed_basecolor"))
//        material.ambientOcclusion.content = UIImage(named: getArtResourcesPath(folder: folder, name: "ao"))
        material.metalness.content = UIImage(named: getArtResourcesPath(folder: folder, name: "Titanium-Scuffed_metallic"))
        material.normal.content = UIImage(named: getArtResourcesPath(folder: folder, name: "Titanium-Scuffed_normal"))
        material.roughness.content = UIImage(named: getArtResourcesPath(folder: folder, name: "Titanium-Scuffed_roughness"))
//        let t = UIImage(named: getArtResourcesPath(folder: folder, name: "Iron-Scuffed_roughness"))
        return material
    }

    func createSphere() -> GIRNode {
        let size: Float = 10
        let geo = GIRGeometry(basic: .sphere(size: float3(size, size, size), segments: [100, 100]))
        return GIRNode.init(geometry: geo)
    }

    func getArtResourcesPath(folder: String, name: String, ext: String = "png") -> String {
        return "Art.scnassets/\(folder)/\(name).\(ext)"
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
