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

    func load(image: UIImage) -> MTLTexture? {
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)

        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }

        let region = MTLRegionMake2D(0, 0, width, height)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width

        var data = getData(from: image)
        texture.replace(region: region, mipmapLevel: 0, withBytes: data!, bytesPerRow: bytesPerRow)
        data = nil

        return texture
    }

    func load(path: String) -> MTLTexture? {
        guard let image = UIImage(named: path) else {
            return nil
        }

        return load(image: image)
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
            guard let image = UIImage(named: images[i]) else {
                return nil
            }

            var data = getData(from: image)
            if data != nil {
                texture.replace(region: region, mipmapLevel: 0, slice: i, withBytes: data!, bytesPerRow: bytesPerRow, bytesPerImage: bytesPerImage)
            }

            data = nil
        }

        return texture
    }

    func load(hdrPath: String) -> MTLTexture? {
        var width = 0
        var height = 0
        var numsOfComponent = 0

        let data = GIRHDRLoader.loadHDR(hdrPath, width: &width, height: &height, numComponents: &numsOfComponent)
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba32Float, width: width, height: height, mipmapped: true)

        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }

        let region = MTLRegionMake2D(0, 0, width, height)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width * MemoryLayout<Float>.size

        texture.replace(region: region, mipmapLevel: 0, withBytes: data!, bytesPerRow: bytesPerRow)
        return texture
    }

    private func getData(from image: UIImage) -> UnsafeMutableRawPointer? {
        guard let imageRef = image.cgImage else {
            return nil
        }

        let bytesPerPixel = 4
        let bitsPerComponent = 8

        let width = imageRef.width
        let height = imageRef.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = calloc(height * width * 4, MemoryLayout<UInt8>.size)

        guard let context = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: width * bytesPerPixel, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue) else {
            return nil
        }

        context.draw(imageRef, in: CGRect(x: 0, y: 0, width: width, height: height))

        return rawData!
    }

//    private func fillData(data: UnsafeMutableRawPointer?, width: Int, height: Int, numOfComponent: Int) {
//        var output: [Float]
//        for i in 0..<height {
//            for j in 0..<width {
//                let index = (i * width + j) * numOfComponent
//
//
//            }
//        }
//    }
}
