//
//  GIRUniforms.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd

struct GIRVertexUniforms {
    var viewProjectionMatrix: float4x4
    var modelMatrix: float4x4
}

struct GIRFragmentUniforms {
    var lightColor = float3(1, 1, 0.5)
    var lightPosition = float3(0, 0, 20)
    var matDiffuse = float3(1, 1, 1)
    var matSpecular = float3(1, 1, 1)
    var matAmbient = float3(1, 1, 1)
    var matShininess = float3(1, 1, 1)
    
    static let length = MemoryLayout<Float>.stride * 16
}
