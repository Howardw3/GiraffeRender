//
//  Matrix4.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import GLKit

struct Matrix4 {
    static let count = 16
    static let size = MemoryLayout<Float>.size
    static let length = MemoryLayout<Float>.size * 16

    private(set) var m: float4x4

    static func convertGLKToSimd(_ m: GLKMatrix4) -> float4x4 {
        return float4x4(float4(m.m00, m.m01, m.m02, m.m03),
                        float4( m.m10, m.m11, m.m12, m.m13 ),
                        float4( m.m20, m.m21, m.m22, m.m23 ),
                        float4( m.m30, m.m31, m.m32, m.m33 ))
    }

    public init(m: float4x4) {
        self.m = m
    }

    init() {
        self.m = matrix_identity_float4x4
    }

    static func translationMatrix(_ position: float3) -> float4x4 {
        var m = matrix_identity_float4x4
        m.columns.3.x = position.x
        m.columns.3.y = position.y
        m.columns.3.z = position.z
        return m
    }

    static func scaleMatrix(_ scale: Float) -> float4x4 {
        var m = matrix_identity_float4x4
        m.columns.0.x = scale
        m.columns.1.y = scale
        m.columns.2.z = scale
        return m
    }

    static func rotationMatrix(angle: Float, axis: float3) -> float4x4 {
        let cos = cosf(angle)
        let cosp = 1.0 - cos
        let sin = sinf(angle)
        let v = normalize(axis)

        let colx = float4(cos + cosp * v.x * v.x,
                          cosp * v.x * v.y + v.z * sin,
                          cosp * v.x * v.z - v.y * sin,
                          0.0)

        let coly = float4(cosp * v.x * v.y - v.z * sin,
                          cos + cosp * v.y * v.y,
                          cosp * v.y * v.z + v.x * sin,
                          0.0)

        let colz = float4(cosp * v.x * v.z + v.y * sin,
                          cosp * v.y * v.z - v.x * sin,
                          cos + cosp * v.z * v.z,
                          0.0)

        let colw = float4(0, 0, 0, 1)
        return float4x4(columns: (colx, coly, colz, colw))
    }

    static func perspective(fovy fovyRadians: Float, aspect: Float, nearZ: Float, farZ: Float) -> float4x4 {
        let cotan = 1.0 / tanf(fovyRadians / 2.0)

        let colx = float4(cotan / aspect, 0.0, 0.0, 0.0)
        let coly = float4(0.0, cotan, 0.0, 0.0)
        let colz = float4(0.0, 0.0, (farZ + nearZ) / (nearZ - farZ), -1.0)
        let colw = float4(0.0, 0.0, (2.0 * farZ * nearZ) / (nearZ - farZ), 0.0)

        return float4x4(colx, coly, colz, colw)
    }
}
