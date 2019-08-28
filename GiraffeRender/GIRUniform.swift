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
    var normalMatrix: float3x3
    var lightSpaceMatrix: float4x4
}

struct GIRFragmentUniforms {
    var cameraPosition = float3(0, 0, 0)
    var matShininess = Float(3)
    var colorTypes: [Float] = Array(repeating: 1.0, count: 5)
    var colors: [float3] = Array(repeating: float3(1.0, 1.0, 1.0), count: 5)

    static let length = MemoryLayout<Float>.stride * (9 + 5 * 3)
    var raw: [Float] {
        var array = [cameraPosition.x, cameraPosition.y, cameraPosition.z, matShininess]
        for item in colorTypes {
            array.append(item)
        }

        for item in colors {
            array.append(item.x)
            array.append(item.y)
            array.append(item.z)
        }
        return array
    }
}

struct GIRShadowUniforms {
    var modelMatrix: float4x4
    var lightSpaceMatrix: float4x4
}
