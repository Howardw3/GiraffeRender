//
//  GIRExtension+float4x4.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd

extension float4x4 {
    static func translationMatrix(_ position: SIMD3<Float>) -> float4x4 {
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

    static func rotationMatrix(angle: Float, axis: SIMD3<Float>) -> float4x4 {
        let cos = cosf(angle)
        let cosp = 1.0 - cos
        let sin = sinf(angle)
        let v = normalize(axis)

        let colx = SIMD4<Float>(cos + cosp * v.x * v.x,
                          cosp * v.x * v.y + v.z * sin,
                          cosp * v.x * v.z - v.y * sin,
                          0.0)

        let coly = SIMD4<Float>(cosp * v.x * v.y - v.z * sin,
                          cos + cosp * v.y * v.y,
                          cosp * v.y * v.z + v.x * sin,
                          0.0)

        let colz = SIMD4<Float>(cosp * v.x * v.z + v.y * sin,
                          cosp * v.y * v.z - v.x * sin,
                          cos + cosp * v.z * v.z,
                          0.0)

        let colw = SIMD4<Float>(0, 0, 0, 1)
        return float4x4(colx, coly, colz, colw)
    }

    static func rotationXMatrix(radians: Float) -> float4x4 {
        let cos = cosf(radians)
        let sin = sinf(radians)
        let colX = SIMD4<Float>(1.0, 0.0, 0.0, 0.0)
        let colY = SIMD4<Float>(0.0, cos, sin, 0.0)
        let colZ = SIMD4<Float>(0.0, -sin, cos, 0.0)
        let colW = SIMD4<Float>(0.0, 0.0, 0.0, 1.0)

        return float4x4(colX, colY, colZ, colW)
    }

    static func rotationYMatrix(radians: Float) -> float4x4 {
        let cos = cosf(radians)
        let sin = sinf(radians)
        let colX = SIMD4<Float>(cos, 0.0, -sin, 0.0)
        let colY = SIMD4<Float>(0.0, 1.0, 0.0, 0.0)
        let colZ = SIMD4<Float>(sin, 0.0, cos, 0.0)
        let colW = SIMD4<Float>(0.0, 0.0, 0.0, 1.0)

        return float4x4(colX, colY, colZ, colW)
    }

    static func rotationZMatrix(radians: Float) -> float4x4 {
        let cos = cosf(radians)
        let sin = sinf(radians)
        let colX = SIMD4<Float>(cos, sin, 0.0, 0.0)
        let colY = SIMD4<Float>(-sin, cos, 0.0, 0.0)
        let colZ = SIMD4<Float>(0.0, 0.0, 1.0, 0.0)
        let colW = SIMD4<Float>(0.0, 0.0, 0.0, 1.0)

        return float4x4(colX, colY, colZ, colW)
    }

    static func perspective(fovy fovyRadians: Float, aspect: Float, nearZ: Float, farZ: Float) -> float4x4 {
        let cotan = 1.0 / tanf(fovyRadians / 2.0)

        let colx = SIMD4<Float>(cotan / aspect, 0.0, 0.0, 0.0)
        let coly = SIMD4<Float>(0.0, cotan, 0.0, 0.0)
        let colz = SIMD4<Float>(0.0, 0.0, (farZ + nearZ) / (nearZ - farZ), -1.0)
        let colw = SIMD4<Float>(0.0, 0.0, (2.0 * farZ * nearZ) / (nearZ - farZ), 0.0)

        return float4x4(colx, coly, colz, colw)
    }

    static func orthoMatrix(left: Float, right: Float, bottom: Float, top: Float, nearZ: Float, farZ: Float) -> float4x4 {
        let ral = right + left
        let rsl = right - left
        let tab = top + bottom
        let tsb = top - bottom
        let fan = farZ + nearZ
        let fsn = farZ - nearZ

        let colx = SIMD4<Float>(2.0 / rsl, 0.0, 0.0, 0.0)
        let coly = SIMD4<Float>(0.0, 2.0 / tsb, 0.0, 0.0)
        let colz = SIMD4<Float>(0.0, 0.0, -2.0 / fsn, 0.0)
        let colw = SIMD4<Float>(-ral / rsl, -tab / tsb, -fan / fsn, 1.0)

        return float4x4(colx, coly, colz, colw)
    }

    static func lookatMatrix(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> float4x4 {

        let n = normalize(eye - center)
        let u = normalize(cross(up, n))
        let v = cross(n, u)

        let colx = SIMD4<Float>(u.x, v.x, n.x, 0.0)
        let coly = SIMD4<Float>(u.y, v.y, n.y, 0.0)
        let colz = SIMD4<Float>(u.z, v.z, n.z, 0.0)
        let colw = SIMD4<Float>(dot(-u, eye), dot(-v, eye), dot(-n, eye), 1.0)

        return float4x4(colx, coly, colz, colw)
    }
}

extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        return SIMD3(x, y, z)
    }

    init(_ lhs: SIMD3<Scalar>, _ rhs: Scalar) {
        self.init(lhs.x, lhs.y, lhs.z, rhs)
    }
}

extension SIMD3 {
    var string: String {
        return "(\(self.x), \(self.y), \(self.z))"
    }
}
