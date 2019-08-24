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
    private var _localRight: float3
    private var _localUp: float3
    private var _localFront: float3
    private var _worldRight: float3
    private var _worldUp: float3
    private var _worldFront: float3

    var children: [GIRNode]
    var parent: GIRNode?
    let identifier = UUID()

    public var geometry: GIRGeometry?
    public var camera: GIRCamera?
    public var light: GIRLight?

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

    public var worldTransform: float4x4 {
        if let parent = parent {
            return parent.worldTransform * transform
        }

        return transform
    }

    public var transform: float4x4 {
        get {
            if _shouldUpdateTransform {
                if let _ = camera  {
                    pivot = float3()
                }
                let translationMatrix = float4x4.translationMatrix(_position)
                let scaleMatrix = float4x4.scaleMatrix(_scale)
                let translatePivotMatrix = float4x4.translationMatrix(pivot)
                let rotationMatrix = float4x4.rotationXMatrix(radians: Float(_rotation.x).radian) * float4x4.rotationYMatrix(radians: Float(_rotation.y).radian) * float4x4.rotationZMatrix(radians: Float(_rotation.z).radian)
                let translateNegPivotMatrix = float4x4.translationMatrix(-pivot)

                _transform = translatePivotMatrix * scaleMatrix * rotationMatrix * translateNegPivotMatrix * translationMatrix
                _shouldUpdateTransform = false
            }

            var tmpDir = float3()
            tmpDir.x = cos(_rotation.x.radian) * cos(_rotation.y.radian)
            tmpDir.y = sin(_rotation.x.radian)
            tmpDir.z = sin(_rotation.y.radian) * cos(_rotation.x.radian)


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

extension GIRNode {
    var localRight: float3 {
        get {

        }
        set {

        }
    }
}

extension GIRNode {
    public func addChild(_ node: GIRNode) {
        if let parent = node.parent {
            if parent == self {
                return
            }
            removeFromParent(node, parent)
        }
        children.append(node)
        node.parent = self
    }

    func removeFromParent(_ node: GIRNode, _ parent: GIRNode) {
        for i in 0..<parent.children.count {
            if parent.children[i] == node {
                parent.children.remove(at: i)
                break
            }
        }
    }
}

extension GIRNode {
    static func ==(lhs: GIRNode, rhs: GIRNode) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
