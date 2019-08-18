//
//  GIRLight.swift
//  GiraffeRender
//
//  Created by Jiongzhi Wang on 8/17/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd

public class GIRLight {
    public enum LightType {
        case ambient
        case directional
        case omini
        case spot
    }
    
    public var type: LightType
    public var color: CGColor
    public init(type: LightType) {
        self.type = type
        self.color = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1, 1, 1, 1])!
    }
    
    public convenience init() {
        self.init(type: .ambient)
    }
}
