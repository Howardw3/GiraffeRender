//
//  GIRCube.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import MetalKit
open class GIRCube: GIRGeometry {
    let vertexLength = MemoryLayout<GIRVertex>.stride * 8
    let indexLength = MemoryLayout<UInt16>.size * 36

    let vertexData = [
        GIRVertex(pos: [-1.0, -1.0, 1.0, 1.0], col: [1.0, 0.0, 0.0, 1]),
        GIRVertex(pos: [ 1.0, -1.0, 1.0, 1.0], col: [0.0, 1.0, 0.0, 1]),
        GIRVertex(pos: [ 1.0, 1.0, 1.0, 1.0], col: [0.0, 0.0, 1.0, 1]),
        GIRVertex(pos: [-1.0, 1.0, 1.0, 1.0], col: [1.0, 1.0, 1.0, 1]),

        GIRVertex(pos: [-1.0, -1.0, -1.0, 1.0], col: [1.0, 0.0, 0.0, 1]),
        GIRVertex(pos: [ 1.0, -1.0, -1.0, 1.0], col: [0.0, 1.0, 0.0, 1]),
        GIRVertex(pos: [ 1.0, 1.0, -1.0, 1.0], col: [0.0, 0.0, 1.0, 1]),
        GIRVertex(pos: [-1.0, 1.0, -1.0, 1.0], col: [1.0, 1.0, 1.0, 1])
    ]

    let indexData: [UInt16] = [
        // front
        0, 1, 2, 2, 3, 0,
        // right
        1, 5, 6, 6, 2, 1,
        // back
        7, 6, 5, 5, 4, 7,
        // left
        4, 0, 3, 3, 7, 4,
        // bottom
        4, 5, 1, 1, 0, 4,
        // top
        3, 2, 6, 6, 7, 3
    ]

    public init() {
        let device = MTLCreateSystemDefaultDevice()
        let allocator = MTKMeshBufferAllocator(device: device!)

        let indexBuffer = allocator.newBuffer(indexLength, type: .index)
        indexBuffer.fill((NSData(bytes: indexData, length: indexLength) as Data), offset: 0)

        let submesh = MDLSubmesh(indexBuffer: indexBuffer,
                                 indexCount: indexData.count,
                                 indexType: .uInt16,
                                 geometryType: .triangles,
                                 material: nil)

        let vertexBuffer = allocator.newBuffer(vertexLength, type: .vertex)
        vertexBuffer.fill(Data(bytes: vertexData, count: vertexLength), offset: 0)
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float4,
                                                            offset: 0,
                                                            bufferIndex: 0)

        let mesh = MDLMesh(vertexBuffer: vertexBuffer, vertexCount: vertexData.count, descriptor: vertexDescriptor, submeshes: [submesh])
        let mtkMesh = try! MTKMesh(mesh: mesh, device: device!)

        super.init(mesh: mtkMesh)
    }
}