//
//  GIRLight.swift
//  GiraffeRender
//
//  Created by Jiongzhi Wang on 8/17/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd

public class GIRLight {
    public var type: LightType
    public var color: CGColor
    public var name: String
    public var intensity: Float
    public var spotInnerAngle: Float
    public var spotOuterAngle: Float
    var direction: float3
    var convertedColor: float3 {
        var ret = float3(1.0, 1.0, 1.0)
        if let arr = color.components, arr.count > 2 {
            ret = float3(Float(arr[0]), Float(arr[1]), Float(arr[2]))
        }
        return ret
    }

    public init(type: LightType) {
        self.type = type
        self.color = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1, 1, 1, 1])!
        self.name = "Light_" + UUID().uuidString
        self.intensity = 1.0
        self.direction = float3(0, 0, -1)
        self.spotInnerAngle = 30.0
        self.spotOuterAngle = 40.0
    }

    public convenience init() {
        self.init(type: .ambient)
    }

    func updateDirection(pitch: Float, yaw: Float) {
        var tmpDir = float3()
        tmpDir.x = cos(pitch) * cos(yaw)
        tmpDir.y = sin(pitch)
        tmpDir.z = sin(yaw) * cos(pitch)
        self.direction = tmpDir
    }
}

extension GIRLight {
    public enum LightType {
        case ambient
        case directional
        case omini
        case spot
    }

    struct LightRaw {
        var positionX: Float = 0.0
        var positionY: Float = 0.0
        var positionZ: Float = 0.0
        var directionX: Float = 0.0
        var directionY: Float = 0.0
        var directionZ: Float = 0.0
        var colorR: Float = 1.0
        var colorG: Float = 1.0
        var colorB: Float = 1.0
        var intensity: Float = 1.0
        var spotInnerRadian: Float = Float(10).radian
        var spotOuterRadian: Float = Float(17).radian

        static let length = MemoryLayout<LightRaw>.stride

        init(position: float3, direction: float3, color: float3) {
            self.positionX = position.x
            self.positionY = position.y
            self.positionZ = position.z
            self.directionX = direction.x
            self.directionY = direction.y
            self.directionZ = direction.z
            self.colorR = color.x
            self.colorG = color.y
            self.colorB = color.z
        }

        init() {
        }
    }
}
