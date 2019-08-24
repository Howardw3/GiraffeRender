//
//  GIRExtension+float4x4.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd

extension float4x4 {
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
        return float4x4(colx, coly, colz, colw)
    }

    static func rotationXMatrix(radians: Float) -> float4x4 {
        let cos = cosf(radians)
        let sin = sinf(radians)
        let colX = float4(1.0, 0.0, 0.0, 0.0)
        let colY = float4(0.0, cos, sin, 0.0)
        let colZ = float4(0.0, -sin, cos, 0.0)
        let colW = float4(0.0, 0.0, 0.0, 1.0)

        return float4x4(colX, colY, colZ, colW)
    }

    static func rotationYMatrix(radians: Float) -> float4x4 {
        let cos = cosf(radians)
        let sin = sinf(radians)
        let colX = float4(cos, 0.0, -sin, 0.0)
        let colY = float4(0.0, 1.0, 0.0, 0.0)
        let colZ = float4(sin, 0.0, cos, 0.0)
        let colW = float4(0.0, 0.0, 0.0, 1.0)

        return float4x4(colX, colY, colZ, colW)
    }

    static func rotationZMatrix(radians: Float) -> float4x4 {
        let cos = cosf(radians)
        let sin = sinf(radians)
        let colX = float4(cos, sin, 0.0, 0.0)
        let colY = float4(-sin, cos, 0.0, 0.0)
        let colZ = float4(0.0, 0.0, 1.0, 0.0)
        let colW = float4(0.0, 0.0, 0.0, 1.0)

        return float4x4(colX, colY, colZ, colW)
    }

    static func perspective(fovy fovyRadians: Float, aspect: Float, nearZ: Float, farZ: Float) -> float4x4 {
        let cotan = 1.0 / tanf(fovyRadians / 2.0)

        let colx = float4(cotan / aspect, 0.0, 0.0, 0.0)
        let coly = float4(0.0, cotan, 0.0, 0.0)
        let colz = float4(0.0, 0.0, (farZ + nearZ) / (nearZ - farZ), -1.0)
        let colw = float4(0.0, 0.0, (2.0 * farZ * nearZ) / (nearZ - farZ), 0.0)

        return float4x4(colx, coly, colz, colw)
    }

    static func lookatMatrix(eye: float3, center: float3, up: float3) ->float4x4 {

        let n = normalize(eye + -center)
        let u = normalize(cross(up, n))
        let v = cross(n, u)

        let colx = float4(u.x, v.x, n.x, 0.0)
        let coly = float4(u.y, v.y, n.y, 0.0)
        let colz = float4(u.z, v.z, n.z, 0.0)
        let colw = float4(dot(-u, eye), dot(-v, eye), dot(-n, eye), 1.0)

        return float4x4(colx, coly, colz, colw)
    }
}

extension float4 {
    var xyz: float3 {
        return float3(x, y, z)
    }
}
