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
    public var albedoTexture: MTLTexture
    public var diffuse: float3 = float3(1, 1, 1)
    public var ambient: float3 = float3(1, 1, 1)
    public var specular: float3 = float3(1, 1, 1)
    public var shininess: Float = 1.0

    init(texture: MTLTexture) {
        albedoTexture = texture
    }
}
