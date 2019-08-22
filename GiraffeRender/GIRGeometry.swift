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
    let device: MTLDevice? = MTLCreateSystemDefaultDevice()

    public init(mesh: MTKMesh) {
        self.mesh = mesh
        self.materials = []
        textureLoader = MTKTextureLoader(device: device!)
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
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                                                            format: .float2,
                                                            offset: MemoryLayout<Float>.stride * 6,
                                                            bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<Float>.stride * 8)

        let url = Bundle.main.url(forResource: name, withExtension: ext)
        let asset = MDLAsset(url: url, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
        let mesh = try! MTKMesh.newMeshes(asset: asset, device: device!).metalKitMeshes.first!
        self.init(mesh: mesh)
    }

    public func addMaterial(name: String) {
        let options: [MTKTextureLoader.Option: Any] = [.generateMipmaps: true, .SRGB: true]
        var texture: MTLTexture?
        do {
//            var image = UIImage(named: name)?.cgImage!
//            let data = UIImage(named: name)!
//            let data = Data
//            let device = MTLCreateSystemDefaultDevice()
//            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Uint, width: image!.width, height: image!.height, mipmapped: false)
//            guard let texture: MTLTexture = device!.makeTexture(descriptor: textureDescriptor) else { return }
//            let region = MTLRegionMake2D(0, 0, Int(image!.width), Int(image!.height))
//            texture.replace(region: region, mipmapLevel: 0, withBytes: &image, bytesPerRow: 8 * image!.width)
            try texture = textureLoader.newTexture(name: name,
                                            scaleFactor: 1.0,
                                                        bundle: Bundle.main,
                                                        options: options)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
//        let device = MTLCreateSystemDefaultDevice()
//        let url = Bundle.main.url(forResource: name, withExtension: "png")
//        let texture = loadEXRTexture(url!, device: device!)
        if let texture = texture {
            materials.append(GIRMaterial(texture: texture))
        }
    }

    // https://stackoverflow.com/questions/48872043/how-to-load-16-bit-images-into-metal-textures
    func convertRGBF32ToRGBAF16(_ src: UnsafePointer<Float>, _ dst: UnsafeMutablePointer<UInt16>, pixelCount: Int) {
        for i in 0..<pixelCount {
            storeAsF16(src[i * 3 + 0], dst + (i * 4) + 0)
            storeAsF16(src[i * 3 + 1], dst + (i * 4) + 1)
            storeAsF16(src[i * 3 + 2], dst + (i * 4) + 2)
            storeAsF16(1.0, dst + (i * 4) + 3)
        }
    }

    func loadEXRTexture(_ url: URL, device: MTLDevice) -> MTLTexture? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }

        let options = [ kCGImageSourceShouldCache: true, kCGImageSourceShouldAllowFloat: true ] as CFDictionary
        guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, options) else { return nil }

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Float,
                                                                  width: image.width,
                                                                  height: image.height,
                                                                  mipmapped: false)
        descriptor.usage = .shaderRead
        guard let texture = device.makeTexture(descriptor: descriptor) else { return nil }

        if image.bitsPerComponent == 32 && image.bitsPerPixel == 96 {
            let srcData: CFData! = image.dataProvider?.data
            CFDataGetBytePtr(srcData).withMemoryRebound(to: Float.self, capacity: image.width * image.height * 3) { srcPixels in
                let dstPixels = UnsafeMutablePointer<UInt16>.allocate(capacity: 4 * image.width * image.height)
                convertRGBF32ToRGBAF16(srcPixels, dstPixels, pixelCount: image.width * image.height)
                texture.replace(region: MTLRegionMake2D(0, 0, image.width, image.height),
                                mipmapLevel: 0,
                                withBytes: dstPixels,
                                bytesPerRow: MemoryLayout<UInt16>.size * 4 * image.width)
                dstPixels.deallocate()
            }
        }

        return texture
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
