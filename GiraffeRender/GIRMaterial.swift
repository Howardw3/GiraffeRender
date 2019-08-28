//
//  GIRMaterial.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/12/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import Foundation
import simd

public class GIRMaterial {
    public var albedo: GIRMaterialProperty
    public var diffuse: GIRMaterialProperty
    public var ambient: GIRMaterialProperty
    public var specular: GIRMaterialProperty
    public var normal: GIRMaterialProperty
    public var shininess: Float

    public init() {
        albedo = GIRMaterialProperty()
        diffuse = GIRMaterialProperty()
        ambient = GIRMaterialProperty()
        specular = GIRMaterialProperty()
        normal = GIRMaterialProperty()
        shininess = 1.0
    }
}

extension GIRMaterial {
    enum PropertyType {
        case albedo
        case diffuse
        case ambient
        case specular
        case normal
    }

    struct Data {
        var textures = [MTLTexture]()
        var colors = [float3]()
        var colorTypes = [Float]()

        enum ColorType: Int {
            case color = 1
            case texture = -1
            case none = 0
        }

        mutating func fillMaterial(_ property: GIRMaterialProperty,
                                   type: PropertyType,
                                   defaultColor: float3 = float3(1.0, 1.0, 1.0)) {

            if let color = property._content.color {
                colors.append(color)
                setTypes(.color)
            } else if let texture = property._content.texture {
                textures.append(texture)
                colors.append(defaultColor)
                setTypes(.texture)
            } else {
                colors.append(defaultColor)
                setTypes(.none)
            }
        }

        private mutating func setTypes(_ type: ColorType) {
            colorTypes.append(Float(type.rawValue))
        }
    }

    var data: Data {
        var ret = Data()
        ret.fillMaterial(albedo, type: .albedo)
        ret.fillMaterial(diffuse, type: .diffuse)
        ret.fillMaterial(ambient, type: .ambient)
        ret.fillMaterial(specular, type: .specular)
        ret.fillMaterial(normal, type: .normal, defaultColor: float3(0.0, 0.0, 1.0))

        return ret
    }
}

