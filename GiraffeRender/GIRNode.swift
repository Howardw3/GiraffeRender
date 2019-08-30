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
    private var _worldTransform: float4x4
    private var shouldUpdateTransform: Bool
    private var shouldUpdateWorldTransform: Bool

    private var _localRight: float3
    private var _localUp: float3
    private var _localFront: float3
//    private var _worldRight: float3
//    private var _worldUp: float3
//    private var _worldFront: float3

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
            shouldUpdateTransform = true
        }
    }

    public var rotation: float4 {
        get {
            return _rotation
        }
        set(newVal) {
            _rotation = newVal
            shouldUpdateTransform = true
        }
    }

    public var scale: Float {
        get {
            return _scale
        }
        set(newVal) {
            _scale = newVal
            shouldUpdateTransform = true
        }
    }

    public var eularAngles: float3 {
        get {
            return _eularAngles
        }
        set(newVal) {
            _rotation = float4(newVal.x, newVal.y, newVal.z, 0.0)
            _eularAngles = newVal
            shouldUpdateTransform = true
        }
    }

    public var pivot = float3()

    // TODO: need to optimize only update only parent change.
    public var worldTransform: float4x4 {
        if let parent = parent {
            return parent.worldTransform * transform
        }

        return _transform
    }

    public var transform: float4x4 {
        get {
            if shouldUpdateTransform {
                if let _ = camera {
                    pivot = float3()
                }
                let translationMatrix = float4x4.translationMatrix(_position)
                let scaleMatrix = float4x4.scaleMatrix(_scale)
                let translatePivotMatrix = float4x4.translationMatrix(pivot)
                let rotationMatrix = float4x4.rotationXMatrix(radians: Float(_rotation.x).radian)
                                   * float4x4.rotationYMatrix(radians: Float(_rotation.y).radian)
                                   * float4x4.rotationZMatrix(radians: Float(_rotation.z).radian)
                let translateNegPivotMatrix = float4x4.translationMatrix(-pivot)

                _transform = translatePivotMatrix * scaleMatrix * rotationMatrix * translateNegPivotMatrix * translationMatrix

                shouldUpdateTransform = false

            }
            updateLocalAxis()
            return _transform
        }
    }

    public init(geometry: GIRGeometry?) {
        self.geometry = geometry
        self._transform = matrix_identity_float4x4
        self._worldTransform = matrix_identity_float4x4
        self._position = float3()
        self._rotation = float4()
        self._scale = 1.0
        self.children = []
        self._eularAngles = float3()
        self.shouldUpdateTransform = false
        self.shouldUpdateWorldTransform = false

        self._localUp = float3(0.0, 1.0, 0.0)
        self._localFront = float3(0.0, 0.0, -1.0)
        self._localRight = float3(1.0, 0.0, 0.0)
//        updateLocalAxis()
    }

    public convenience init() {
        self.init(geometry: nil)
    }
}

extension GIRNode {
    var localRight: float3 {
        return _localRight
    }

    var localUp: float3 {
        return _localUp
    }

    var localFront: float3 {
        return _localFront
    }

    var worldRight: float3 {
        if let parent = parent {
            return parent.worldRight * _localRight
        }

        return _localRight
    }

    var worldUp: float3 {
        if let parent = parent {
            return parent.worldUp * _localUp
        }

        return _localUp
    }

    var worldFront: float3 {
        if let parent = parent {
            return parent.worldFront * _localFront
        }

        return _localFront
    }

    func updateLocalAxis() {
        var front = float3()
        front.x = cos(_rotation.x.radian) * cos(_rotation.y.radian)
        front.y = sin((_rotation.x).radian)
        front.z = cos(_rotation.x.radian) * sin(_rotation.y.radian)

        _localFront = normalize(front)
        _localRight = normalize(cross(_localFront, worldUp))
        _localUp = normalize(cross(_localRight, _localFront))
    }

    public func debugPrintLocalAxis() {
        debugPrint("up:\(_localUp.string), front: \(_localFront.string), right: \(_localRight.string)")
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
