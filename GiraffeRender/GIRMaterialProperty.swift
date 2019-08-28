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
    
    public var content: Any? {
        get {
            return _content.val
        }
        set(newVal) {
            if let val = newVal as? float3 {
                _content = Content(color: val)
            }
            if let val = newVal as? String {
                _content = Content(texturePath: val)
            }
        }
    }

    struct Content {
        var color: float3? {
            didSet {
                self.texturePath = nil
            }
        }
        var texturePath: String? {
            didSet {
                self.color = nil
            }
        }
        var texture: MTLTexture?

        init(color: float3) {
            self.color = color
            self.texturePath = nil
            self.texture = nil
        }

        init(texturePath: String) {
            self.color = nil
            self.texturePath = texturePath
            loadTexture(path: texturePath)
        }

        init() {
        }

        var val: Any? {
            return color != nil ? color : texturePath
        }

        mutating func loadTexture(path: String) {
            let device: MTLDevice? = MTLCreateSystemDefaultDevice()
            let textureLoader = MTKTextureLoader(device: device!)

            let options: [MTKTextureLoader.Option: Any] = [.generateMipmaps: true, .SRGB: true]
            var texture: MTLTexture?
            do {
                try texture = textureLoader.newTexture(name: path,
                                                       scaleFactor: 1.0,
                                                       bundle: Bundle.main,
                                                       options: options)
            } catch let error {
                debugPrint(error.localizedDescription)
            }

            self.texture = texture
        }
    }
}

extension GIRMaterialProperty {
    enum ColorType: Int {
        case color
        case texture
    }
}
