//
//  Geometry.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd
import MetalKit

open class GIRGeometry {
    public var mesh: MTKMesh
    public var materials: [GIRMaterial]
    var textureLoader: MTKTextureLoader

    public init(mesh: MTKMesh) {
        self.mesh = mesh
        self.materials = []
        textureLoader = MTKTextureLoader(device: MTLCreateSystemDefaultDevice()!)
    }

    convenience public init(name: String, ext: String) {
        let device = MTLCreateSystemDefaultDevice()
        let bufferAllocator = MTKMeshBufferAllocator(device: device!)
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float3,
                                                            offset: 0,
                                                            bufferIndex: 0)
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                                                            format: .float2,
                                                            offset: MemoryLayout<Float>.size * 3,
                                                            bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<Float>.size * 5)

        let url = Bundle.main.url(forResource: name, withExtension: ext)
        let bobAsset = MDLAsset(url: url, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
        let mesh = try! MTKMesh.newMeshes(asset: bobAsset, device: device!).metalKitMeshes.first!
        self.init(mesh: mesh)
    }

    public func addMaterial(name: String) {
        let options: [MTKTextureLoader.Option: Any] = [.generateMipmaps: true, .SRGB: true]
        let baseColorTexture = try? textureLoader.newTexture(name: name,
                                                               scaleFactor: 1.0,
                                                               bundle: nil,
                                                               options: options)

        materials.append(GIRMaterial(texture: baseColorTexture!))

    }
}
