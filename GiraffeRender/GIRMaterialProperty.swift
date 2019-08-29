//
//  GIRMaterialProperty.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/21/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd
import MetalKit

public class GIRMaterialProperty {
    var _content: Content = Content()
    let device: MTLDevice? = MTLCreateSystemDefaultDevice()
    lazy var textureLoader: MTKTextureLoader = {
        return MTKTextureLoader(device: device!)
    }()

    public var content: Any? {
        get {
            return _content.val
        }
        set(newVal) {
            if let val = newVal as? float3 {
                _content = Content(color: val)
            } else if let val = newVal as? String {
                _content = Content(texturePath: val, textureLoader: textureLoader)
            } else if let val = newVal as? UIImage {
                _content = Content(image: val, textureLoader: textureLoader)
            }
        }
    }

    struct Content {
        let options: [MTKTextureLoader.Option: Any] = [.generateMipmaps: true, .SRGB: true]
        var texture: MTLTexture?
        var textureLoader: MTKTextureLoader?

        var color: float3? {
            didSet {
                self.texturePath = nil
                self.texture = nil
            }
        }

        var texturePath: String? {
            didSet {
                self.color = nil
            }
        }

        init(color: float3) {
            self.color = color
            self.texturePath = nil
            self.texture = nil
        }

        init(texturePath: String, textureLoader: MTKTextureLoader) {
            self.color = nil
            self.texturePath = texturePath
            self.textureLoader = textureLoader
            loadTexture(path: texturePath)
        }

        init(image: UIImage, textureLoader: MTKTextureLoader) {
            self.color = nil
            self.texturePath = nil
            self.textureLoader = textureLoader
            loadTexture(image: image)
        }

        init() {
        }

        var val: Any? {
            return color != nil ? color : texture
        }

        mutating func loadTexture(image: UIImage) {
            do {
                try texture = textureLoader?.newTexture(cgImage: image.cgImage!, options: options)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }

        mutating func loadTexture(path: String) {
            do {
                try texture = textureLoader?.newTexture(name: path,
                                                       scaleFactor: 1.0,
                                                       bundle: Bundle.main,
                                                       options: options)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

extension GIRMaterialProperty {
    enum ColorType: Int {
        case color
        case texture
    }
}
