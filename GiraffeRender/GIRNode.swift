//
//  Node.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd

public class GIRNode {
    private var _position: float3
    private var _scale: Float
    private var _rotation: float4
    private var _eularAngles: float3
    private var _transform: float4x4
    private var _shouldUpdateTransform: Bool
    var children: [GIRNode]

    public var geometry: GIRGeometry?
    public var camera: GIRCamera?
    public var light: GIRLight?

    public func addChild(_ node: GIRNode) {
        children.append(node)
    }

    public var position: float3 {
        get {
            return _position
        }
        set(newVal) {
            pivot = newVal
            _position = newVal
            _shouldUpdateTransform = true
        }
    }

    public var rotation: float4 {
        get {
            return _rotation
        }
        set(newVal) {
            _rotation = newVal
            _shouldUpdateTransform = true
        }
    }

    public var scale: Float {
        get {
            return _scale
        }
        set(newVal) {
            _scale = newVal
            _shouldUpdateTransform = true
        }
    }

    public var eularAngles: float3 {
        get {
            return _eularAngles
        }
        set(newVal) {
            _rotation = float4(newVal.x, newVal.y, newVal.z, 0.0)
            _eularAngles = newVal
            _shouldUpdateTransform = true
        }
    }

    public var pivot = float3()

    public var transform: float4x4 {
        get {
            if _shouldUpdateTransform {
                let translationMatrix = float4x4.translationMatrix(_position)
                let scaleMatrix = float4x4.scaleMatrix(_scale)
                let translatePivotMatrix = float4x4.translationMatrix(pivot)
                let rotationMatrix = float4x4.rotationXMatrix(radians: Float(_rotation.x).radian) * float4x4.rotationYMatrix(radians: Float(_rotation.y).radian) * float4x4.rotationZMatrix(radians: Float(_rotation.z).radian)
                let translateNegPivotMatrix = float4x4.translationMatrix(-pivot)

                _transform = translatePivotMatrix * scaleMatrix * rotationMatrix * translateNegPivotMatrix * translationMatrix
                _shouldUpdateTransform = false
            }

            return _transform
        }
    }

    public init(geometry: GIRGeometry?) {
        self.geometry = geometry
        _transform = matrix_identity_float4x4
        _position = float3()
        _rotation = float4()
        _scale = 1.0
        children = []
        _eularAngles = float3()
        _shouldUpdateTransform = false
    }

    public convenience init() {
        self.init(geometry: nil)
    }
}
