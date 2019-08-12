//
//  GIRCamera.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/11/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import Foundation
import simd

public class GIRCamera {
    internal var shouldUpdateProjMatrix: Bool

    public var name: String?
    public var fieldOfView: Float {
        didSet {
            self.shouldUpdateProjMatrix = true
        }
    }

    public var zNear: Float {
        didSet {
            self.shouldUpdateProjMatrix = true
        }
    }

    public var zFar: Float {
        didSet {
            self.shouldUpdateProjMatrix = true
        }
    }

    public var projectionMatrix: float4x4 {
        didSet {
            self.shouldUpdateProjMatrix = false
        }
    }

    init() {
        self.fieldOfView = 60.0
        self.zNear = 1.0
        self.zFar = 100.0
        self.shouldUpdateProjMatrix = true
        self.projectionMatrix = float4x4()
    }
}
