//
//  GIRTextureLoader.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/29/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import MetalKit

class GIRTextureLoader {
    static let shared = GIRTextureLoader()

    let device: MTLDevice

    private init() {
        device = MTLCreateSystemDefaultDevice()!
    }

    func load(image: CGImage?) -> MTLTexture? {
        guard let image = image else {
            return nil
        }

        let width = image.width
        let height = image.height
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)

        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }

        let region = MTLRegionMake2D(0, 0, width, height)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width

        var outImage: CGImage?
        let data = getData(from: image, width: width, height: height, outImage: &outImage)
        texture.replace(region: region, mipmapLevel: 0, withBytes: data!.bytes, bytesPerRow: bytesPerRow)

//        generateMipmaps(texture: texture, device: device)
//        generateMipmaps(texture: texture, image: image, width: width, height: height)
        return texture
    }

    func load(path: String) -> MTLTexture? {
        guard let image = UIImage(named: path) else {
            return nil
        }

        return load(image: image.cgImage)
    }

    func load(images: [String]) -> MTLTexture? {
        guard let image = UIImage(named: images[0]), images.count == 6 else {
            return nil
        }

        let size = Int(image.size.width * image.scale)
        let textureDescriptor = MTLTextureDescriptor.textureCubeDescriptor(pixelFormat: .rgba8Unorm, size: size, mipmapped: true)

        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }

        let region = MTLRegionMake2D(0, 0, size, size)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * size
        let bytesPerImage = bytesPerRow * size

        for i in 0..<6 {
            guard let image = UIImage(named: images[i]), let imageRef = image.cgImage else {
                return nil
            }

            var outImage: CGImage?
            let data = getData(from: imageRef, width: Int(image.size.width), height: Int(image.size.width), outImage: &outImage)
            if let data = data {
                texture.replace(region: region, mipmapLevel: 0, slice: i, withBytes: data.bytes, bytesPerRow: bytesPerRow, bytesPerImage: bytesPerImage)
            }
        }

        return texture
    }

    func load(hdrPath: String) -> MTLTexture? {
        var width: Int32 = 0
        var height: Int32 = 0
        var numsOfComponent: Int32 = 0

        let data = GIRHDRLoader.loadHDR(hdrPath, width: &width, height: &height, numComponents: &numsOfComponent)
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba32Float, width: Int(width), height: Int(height), mipmapped: true)

        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }

        let region = MTLRegionMake2D(0, 0, Int(width), Int(height))
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * Int(width) * MemoryLayout<Float>.size

        texture.replace(region: region, mipmapLevel: 0, withBytes: data!, bytesPerRow: bytesPerRow)
        return texture
    }

    private func getData(from imageRef: CGImage, width: Int, height: Int, outImage: inout CGImage?) -> NSData? {
        let bytesPerPixel = 4
        let bitsPerComponent = 8

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let dataLength = height * width * 4
        let rawData = calloc(dataLength, MemoryLayout<UInt8>.size)

        guard let context = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: width * bytesPerPixel, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }

        context.draw(imageRef, in: CGRect(x: 0, y: 0, width: width, height: height))

        if outImage != nil {
            outImage = context.makeImage()
        }

        return NSData(bytesNoCopy: rawData!, length: dataLength, freeWhenDone: true)
    }

    private func generateMipmaps(texture: MTLTexture, device: MTLDevice) {
        let commandQueue = device.makeCommandQueue()
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeBlitCommandEncoder()
        commandEncoder?.generateMipmaps(for: texture)
        commandEncoder?.endEncoding()
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
    }

    private func generateMipmaps(texture: MTLTexture, image: CGImage, width: Int, height: Int) {
        var level = 1
        var mipWidth = width / 2
        var mipHeight = height / 2
        var scaledImage: CGImage? = image
        var image = image

        while mipWidth >= 16 && mipHeight >= 16 {
            let mipBytesPerRow = 4 * mipWidth
            let mipData = getData(from: image, width: width, height: height, outImage: &scaledImage)
            image = scaledImage!

            let region = MTLRegionMake2D(0, 0, mipWidth, mipHeight)
            texture.replace(region: region, mipmapLevel: level, withBytes: mipData!.bytes, bytesPerRow: mipBytesPerRow)

            mipWidth /= 2
            mipHeight /= 2
            level += 1
        }
    }
}
