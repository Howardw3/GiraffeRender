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
    var cameraPosition = float3(0, 0, 0)
    var lightColor = float3(1, 0.0, 0.0)
    var lightPosition = float3(0, 0, 2)
    var matDiffuse = float3(1, 1, 1)
    var matSpecular = float3(1, 1, 1)
    var matAmbient = float3(1, 1, 1)
    var matShininess = Float(3)

    static let length = MemoryLayout<Float>.stride * 19
    var raw: [Float] {
        let array = [cameraPosition.x, cameraPosition.y, cameraPosition.z, lightColor.x, lightColor.y, lightColor.z, lightPosition.x, lightPosition.y, lightPosition.z, matDiffuse.x, matDiffuse.y, matDiffuse.z, matSpecular.x, matSpecular.y, matSpecular.z, matAmbient.x, matAmbient.y, matAmbient.z, matShininess]
        return array
    }
    
    
}
