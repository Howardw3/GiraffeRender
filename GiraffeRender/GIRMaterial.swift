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
    struct Data {
        var textures = [MTLTexture]()
        var colors = [float3]()
    }

    var data: Data {
        var colors = [float3]()
        var textures = [MTLTexture]()

        fillMaterialData(albedo, colors: &colors, textures: &textures)
        fillMaterialData(diffuse, colors: &colors, textures: &textures)
        fillMaterialData(ambient, colors: &colors, textures: &textures)
        fillMaterialData(specular, colors: &colors, textures: &textures)
        fillMaterialData(normal, colors: &colors, textures: &textures)

        return Data(textures: textures, colors: colors)
    }

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

    func fillMaterialData(_ property: GIRMaterialProperty, colors: inout [float3], textures: inout [MTLTexture]) {
        if let color = property._content.color {
            colors.append(color)
        } else if let texture = property._content.texture {
            textures.append(texture)
        }
    }
}
