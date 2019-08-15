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
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeNormal,
                                                            format: .float3,
                                                            offset: MemoryLayout<Float>.size * 5,
                                                            bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<Float>.size * 8)

        let url = Bundle.main.url(forResource: name, withExtension: ext)
        let asset = MDLAsset(url: url, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
        let mesh = try! MTKMesh.newMeshes(asset: asset, device: device!).metalKitMeshes.first!
        self.init(mesh: mesh)
    }

    public func addMaterial(name: String) {
        let options: [MTKTextureLoader.Option: Any] = [.generateMipmaps: true, .SRGB: true]
        var texture: MTLTexture?
        do {
            try texture = textureLoader.newTexture(name: name,
                                                        scaleFactor: 1.0,
                                                        bundle: Bundle.main,
                                                        options: options)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        if let texture = texture {
            materials.append(GIRMaterial(texture: texture))
        }
    }
}
