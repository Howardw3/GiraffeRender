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

    func createTexturedCube() -> GIRNode {
        let cube = GIRGeometry(name: "Art.scnassets/textured_cube/textured_cube", ext: "obj")
        let material = GIRMaterial()
        material.albedo.content = UIImage(named: "Art.scnassets/textured_cube/textured_cube_alb.png")
        material.specular.content = UIImage(named: "Art.scnassets/textured_cube/textured_cube_specular.png")
        material.normal.content = UIImage(named: "Art.scnassets/textured_cube/textured_cube_normal.png")

        material.shininess = 1.0
        cube.addMaterial(material)
        return GIRNode(geometry: cube)
    }

    func createCube() -> GIRNode {
        let cube = GIRGeometry(basic: .box(size: float3(1, 1, 1), segments: [10, 10, 10], inward: false))
        let material = GIRMaterial()
        material.albedo.content = "cube_alb"
        cube.addMaterial(material)
        return GIRNode(geometry: cube)
    }

    func createCone() -> GIRNode {
        let cone = GIRGeometry(basic: .cone(size: float3(2, 5, 2), segments: [1, 1], cap: false))
        let material = GIRMaterial()
        material.albedo.content = "cube_alb"
        cone.addMaterial(material)
        return GIRNode(geometry: cone)
    }

    func createPlaneNode() -> GIRNode {
        let plane = GIRGeometry(basic: .plane(size: float3(4, 4, 1), segments: [1, 1]))
        let material = GIRMaterial()
        material.albedo.content = "brickwall_diffuse"
        material.normal.content = "brickwall_normal"
        plane.addMaterial(material)
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

    func createGoldMaterial() -> GIRMaterial {
        let material = GIRMaterial()
        let folder = "gold"
        material.albedo.content = UIImage(named: getArtResourcesPath(folder: folder, name: "albedo"))
        material.ambientOcclusion.content = UIImage(named: getArtResourcesPath(folder: folder, name: "ao"))
        material.metalness.content = UIImage(named: getArtResourcesPath(folder: folder, name: "metallic"))
        material.normal.content = UIImage(named: getArtResourcesPath(folder: folder, name: "normal"))
        material.roughness.content = UIImage(named: getArtResourcesPath(folder: folder, name: "roughness"))
        return material
    }

    func createDreddNode() -> GIRNode {
        let dredd = GIRGeometry(name: "Art.scnassets/dredd/DreddOBJ", ext: "obj")

        let folder = "dredd/Maps/"

        let faceFolder = folder + "Face"
        let faceMaterial = GIRMaterial()
        faceMaterial.albedo.content = UIImage(named: getArtResourcesPath(folder: faceFolder, name: "Face_Diff"))
        faceMaterial.normal.content = UIImage(named: getArtResourcesPath(folder: faceFolder, name: "Tete-NM_u0_v0"))
        faceMaterial.ambientOcclusion.content = UIImage(named: getArtResourcesPath(folder: faceFolder, name: "Face_AO"))
        faceMaterial.roughness.content = UIImage(named: getArtResourcesPath(folder: faceFolder, name: "Tetel2_gloss"))
        faceMaterial.metalness.content = float3(0, 0, 0)

        let torseForder = folder + "Torse/Dredd_Torse_"
        let torseMaterial = GIRMaterial()
        torseMaterial.albedo.content = UIImage(named: getArtResourcesPath(name: torseForder + "BaseColor"))
        torseMaterial.normal.content = UIImage(named: getArtResourcesPath(name: torseForder + "Normal"))
        torseMaterial.ambientOcclusion.content = UIImage(named: getArtResourcesPath(name: torseForder + "AO"))
        torseMaterial.roughness.content = UIImage(named: getArtResourcesPath(name: torseForder + "Roughness"))
        torseMaterial.metalness.content = UIImage(named: getArtResourcesPath(name: torseForder + "Metallic"))

        let dummyForder = folder + "Dummy/Dredd_Dummy_"
        let dummyMaterial = GIRMaterial()
        dummyMaterial.albedo.content = UIImage(named: getArtResourcesPath(name: dummyForder + "BaseColor"))
        dummyMaterial.normal.content = UIImage(named: getArtResourcesPath(name: dummyForder + "Normal"))
        dummyMaterial.ambientOcclusion.content = UIImage(named: getArtResourcesPath(name: dummyForder + "AO"))
        dummyMaterial.roughness.content = UIImage(named: getArtResourcesPath(name: dummyForder + "Roughness"))
        dummyMaterial.metalness.content = UIImage(named: getArtResourcesPath(name: dummyForder + "Metallic"))

        let helmetForder = folder + "Helmet/DreddCasque_Helmet_"
        let helmetMaterial = GIRMaterial()
        helmetMaterial.albedo.content = UIImage(named: getArtResourcesPath(name: helmetForder + "BaseColor", ext: "jpg"))
        helmetMaterial.normal.content = UIImage(named: getArtResourcesPath(name: helmetForder + "Normal", ext: "jpg"))
        helmetMaterial.ambientOcclusion.content = UIImage(named: getArtResourcesPath(name: helmetForder + "AO", ext: "jpg"))
        helmetMaterial.roughness.content = UIImage(named: getArtResourcesPath(name: helmetForder + "Roughness", ext: "jpg"))
        helmetMaterial.metalness.content = UIImage(named: getArtResourcesPath(name: helmetForder + "Metallic", ext: "jpg"))

        let dreddNode = GIRNode(geometry: dredd)
        dreddNode.geometry?.materials = [helmetMaterial, faceMaterial, dummyMaterial, torseMaterial]
        dreddNode.name = "dredd"
        dreddNode.position.y = -6
        dreddNode.scale = 0.3
        return dreddNode
    }

    func createSphere() -> GIRNode {
        let size: Float = 10
        let geo = GIRGeometry(basic: .sphere(size: float3(size, size, size), segments: [100, 100]))
        return GIRNode.init(geometry: geo)
    }

    func getArtResourcesPath(folder: String, name: String, ext: String = "png") -> String {
        return "Art.scnassets/\(folder)/\(name).\(ext)"
    }

    func getArtResourcesPath(name: String, ext: String = "png") -> String {
        return "Art.scnassets/\(name).\(ext)"
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
