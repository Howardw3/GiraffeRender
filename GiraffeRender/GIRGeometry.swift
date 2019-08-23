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
    public var material: GIRMaterial?

    public init(mesh: MTKMesh) {
        self.mesh = mesh
    }

    convenience public init(basic: Basic) {
        self.init(mesh: basic.mesh!)
    }

    convenience public init(name: String, ext: String) {
        let device = MTLCreateSystemDefaultDevice()
        let bufferAllocator = MTKMeshBufferAllocator(device: device!)
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float3,
                                                            offset: 0,
                                                            bufferIndex: 0)
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal,
                                                            format: .float3,
                                                            offset: MemoryLayout<Float>.stride * 3,
                                                            bufferIndex: 0)
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTangent,
                                                            format: .float3,
                                                            offset: MemoryLayout<Float>.stride * 6,
                                                            bufferIndex: 0)
        vertexDescriptor.attributes[3] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                                                            format: .float2,
                                                            offset: MemoryLayout<Float>.stride * 9,
                                                            bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<Float>.stride * 11)

        let url = Bundle.main.url(forResource: name, withExtension: ext)
        let asset = MDLAsset(url: url, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
        asset.loadTextures()
        for sourceMesh in asset.childObjects(of: MDLMesh.self) as! [MDLMesh] {
            sourceMesh.addOrthTanBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                                       normalAttributeNamed: MDLVertexAttributeNormal,
                                       tangentAttributeNamed: MDLVertexAttributeTangent)
            sourceMesh.vertexDescriptor = vertexDescriptor
        }

        let mesh = try! MTKMesh.newMeshes(asset: asset, device: device!).metalKitMeshes.first!
        self.init(mesh: mesh)
    }
}

extension GIRGeometry {
    public enum Basic {
        case box(size: float3, segments: vector_uint3)
        case sphere(size: float3, segments: vector_uint2)
        case hemisphere(size: float3, segments: vector_uint2, cap: Bool)
        case cylinder(size: float3, segments: vector_uint2,topCap: Bool, bottomCap: Bool)
        case capsule(size: float3, cylinderSegments: vector_uint2, hemisphereSegments: Int32)
        case cone(size: float3, segments: vector_uint2, cap: Bool)
        case plane(size: float3, segments: vector_uint2)


        var mesh: MTKMesh? {
            guard let device = MTLCreateSystemDefaultDevice() else {
                return nil
            }
            let bufferAllocator = MTKMeshBufferAllocator(device: device)
            switch self {

            case .box(let size, let segments):
                return try? MTKMesh(mesh: MDLMesh(boxWithExtent: size, segments: segments, inwardNormals: false, geometryType: .triangles, allocator: bufferAllocator), device: device)

            case .sphere(let size, let segments):
                return try? MTKMesh(mesh: MDLMesh(sphereWithExtent: size, segments: segments, inwardNormals: false, geometryType: .triangles, allocator: bufferAllocator), device: device)

            case .hemisphere(let size, let segments, let cap):
                return try? MTKMesh(mesh: MDLMesh(hemisphereWithExtent: size, segments: segments, inwardNormals: false, cap: cap, geometryType: .triangles, allocator: bufferAllocator), device: device)

            case .cylinder(let size, let segments, let topCap, let bottomCap):
                return try? MTKMesh(mesh: MDLMesh(cylinderWithExtent: size, segments: segments, inwardNormals: false, topCap: topCap, bottomCap: bottomCap, geometryType: .triangles, allocator: bufferAllocator), device: device)

            case .capsule(let size, let cylinderSegments, let hemisphereSegments):
                return try? MTKMesh(mesh: MDLMesh(capsuleWithExtent: size, cylinderSegments: cylinderSegments, hemisphereSegments: hemisphereSegments, inwardNormals: false, geometryType: .triangles, allocator: bufferAllocator), device: device)

            case .cone(let size, let segments, let cap):
                return try? MTKMesh(mesh: MDLMesh(coneWithExtent: size, segments: segments, inwardNormals: false, cap: cap, geometryType: .triangles, allocator: bufferAllocator), device: device)

            case .plane(let size, let segments):
                return try? MTKMesh(mesh: MDLMesh(planeWithExtent: size, segments: segments, geometryType: .triangles, allocator: bufferAllocator), device: device)
            }
        }
    }
}
