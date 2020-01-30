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
            if let val = newVal as? SIMD3<Float> {
                _content = Content(color: val)
            } else if let val = newVal as? String {
                _content = Content(texturePath: val)
            } else if let val = newVal as? UIImage {
                _content = Content(image: val)
            } else if let val = newVal as? [String] {
                _content = Content(images: val)
            }
        }
    }

    struct Content {
        var texture: MTLTexture? {
            didSet {
                self.color = nil
            }
        }

        var color: SIMD3<Float>? {
            didSet {
                self.texture = nil
            }
        }

        init(color: SIMD3<Float>) {
            self.color = color
            self.texture = nil
        }

        init(texturePath: String) {
            self.color = nil
            if texturePath.split(separator: ".").last == "hdr" {
                self.texture = GIRTextureLoader.shared.load(hdrPath: texturePath)
            } else {
                self.texture = GIRTextureLoader.shared.load(path: texturePath)
            }
        }

        init(image: UIImage) {
            self.texture = GIRTextureLoader.shared.load(image: image.cgImage)
        }

        init(images: [String]) {
            self.texture = GIRTextureLoader.shared.load(images: images)
        }

        init() {
        }

        var val: Any? {
            return color != nil ? color : texture
        }
    }
}

extension GIRMaterialProperty {
    enum ColorType: Int {
        case color
        case texture
    }
}
