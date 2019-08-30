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
    let textureLoader: MTKTextureLoader
    let options: [MTKTextureLoader.Option: Any] = [.generateMipmaps: true, .SRGB: true]

    private init() {
        device = MTLCreateSystemDefaultDevice()!
        textureLoader = MTKTextureLoader(device: device)
    }

    func load(image: UIImage) -> MTLTexture? {
        var texture: MTLTexture?

        do {
            try texture = textureLoader.newTexture(cgImage: image.cgImage!, options: options)
        } catch let error {
            debugPrint(error.localizedDescription)
        }

        return texture
    }

    func load(path: String) -> MTLTexture? {
        var texture: MTLTexture?

        do {
            try texture = textureLoader.newTexture(name: path,
                                                    scaleFactor: 1.0,
                                                    bundle: Bundle.main,
                                                    options: options)
        } catch let error {
            debugPrint(error.localizedDescription)
        }

        return texture
    }

    func load(images: [String]) -> MTLTexture? {
        guard let image = UIImage(named: images[0]), images.count == 6 else {
            return nil
        }

        let size = Int(image.size.width * image.scale)
        let textureDescriptor = MTLTextureDescriptor.textureCubeDescriptor(pixelFormat: .rgba8Unorm, size: size, mipmapped: false)

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
}
