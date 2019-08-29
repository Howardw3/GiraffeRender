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
    public var ambientOcclusion: GIRMaterialProperty
    public var metalness: GIRMaterialProperty
    public var roughness: GIRMaterialProperty
    public var emission: GIRMaterialProperty
    public var shininess: Float

    public init() {
        albedo = GIRMaterialProperty()
        diffuse = GIRMaterialProperty()
        ambient = GIRMaterialProperty()
        specular = GIRMaterialProperty()
        normal = GIRMaterialProperty()
        ambientOcclusion = GIRMaterialProperty()
        metalness = GIRMaterialProperty()
        roughness = GIRMaterialProperty()
        emission = GIRMaterialProperty()
        shininess = 1.0
    }
}

extension GIRMaterial {
    enum BasicPropertyType {
        case albedo
        case diffuse
        case ambient
        case specular
        case normal
    }

    enum PBRPropertyType {
        case albedo
        case metalness
        case roughness
        case normal
        case ambientOcclusion
        case emission
    }

    struct Data<T> {
        var textures = [MTLTexture]()
        var colors = [float3]()
        var colorTypes = [Float]()

        enum ColorType: Int {
            case color = 1
            case texture = -1
            case none = 0
        }

        mutating func fillMaterial(_ property: GIRMaterialProperty,
                                   type: T,
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

    var basicData: Data<BasicPropertyType> {
        var ret = Data<BasicPropertyType>()
        ret.fillMaterial(albedo, type: .albedo)
        ret.fillMaterial(diffuse, type: .diffuse)
        ret.fillMaterial(ambient, type: .ambient)
        ret.fillMaterial(specular, type: .specular)
        ret.fillMaterial(normal, type: .normal, defaultColor: float3(0.0, 0.0, 1.0))

        return ret
    }

    var pbrData: Data<PBRPropertyType> {
        var ret = Data<PBRPropertyType>()
        ret.fillMaterial(albedo, type: .albedo)
        ret.fillMaterial(metalness, type: .metalness)
        ret.fillMaterial(roughness, type: .roughness)
        ret.fillMaterial(normal, type: .normal, defaultColor: float3(0.0, 0.0, 1.0))
        ret.fillMaterial(ambientOcclusion, type: .ambientOcclusion)
        ret.fillMaterial(emission, type: .emission)
        return ret
    }
}

