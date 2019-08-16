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
                                                            offset: MemoryLayout<Float>.stride * 3,
                                                            bufferIndex: 0)
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeNormal,
                                                            format: .float3,
                                                            offset: MemoryLayout<Float>.stride * 5,
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
