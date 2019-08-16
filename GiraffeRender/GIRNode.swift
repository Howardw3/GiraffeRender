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
    var children: [GIRNode]

    public var geometry: GIRGeometry?

    public var camera: GIRCamera?
    public func addChild(_ node: GIRNode) {
        children.append(node)
    }

    public var position: float3 {
        get {
            return _position
        }
        set(newVal) {
            let delta = newVal - _position
            translate(delta)
            pivot += delta
            _position = newVal
        }
    }

    public var rotation: float4 {
        get {
            return _rotation
        }
        set(newVal) {
            rotate(angle: newVal.w, axis: float3(newVal.x, newVal.y, newVal.z))
            _rotation = newVal
        }
    }

    public var scale: Float {
        get {
            return _scale
        }
        set(newVal) {
            scale(newVal)
            _scale = newVal
        }
    }

    public var eularAngles: float3 {
        get {
            return _eularAngles
        }
        set(newVal) {
            translate(-pivot)
            rotate(angle: Float(newVal.x).radian, axis: float3(1.0, 0.0, 0.0))
            rotate(angle: Float(newVal.y).radian, axis: float3(0.0, 1.0, 0.0))
            rotate(angle: Float(newVal.z).radian, axis: float3(0.0, 0.0, 1.0))
            translate(pivot)
        }
    }

    public var pivot = float3()

    public private(set) var transform: float4x4

    public init(geometry: GIRGeometry?) {
        self.geometry = geometry
        transform = matrix_identity_float4x4
        _position = float3()
        _rotation = float4()
        _scale = 1.0
        children = []
        _eularAngles = float3()
    }

    convenience init() {
        self.init(geometry: nil)
    }

    private func translate(_ position: float3) {
        transform = transform * Matrix4.translationMatrix(position)
    }

    private func scale(_ scale: Float) {
        transform = transform * Matrix4.scaleMatrix(scale)
    }

    private func rotate(angle: Float, axis: float3) {
        transform = Matrix4.rotationMatrix(angle: angle, axis: axis) * transform
    }
}
