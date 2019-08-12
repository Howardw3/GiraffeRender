//
//  Node.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd

public class GIRNode {
    private var _translation: float3
    private var _scale: Float
    private var _rotation: float4
    var children: [GIRNode]

    public var geometry: GIRGeometry?

    public var camera: GIRCamera?
    public func addChild(_ node: GIRNode) {
        children.append(node)
    }

    public var translation: float3 {
        get {
            return _translation
        }
        set(newVal) {
            translate(newVal)
            _translation = newVal
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

    private(set) var transform: float4x4

    public init(geometry: GIRGeometry?) {
        self.geometry = geometry
        transform = matrix_identity_float4x4
        _translation = float3()
        _rotation = float4()
        _scale = 1.0
        children = []
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
