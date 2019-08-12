//
//  GIRCamera.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/11/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import Foundation

public class GIRCamera {

    public var fieldOfView: Float
    public var name: String?
    public var zNear: Float
    public var zFar: Float

    init() {
        fieldOfView = Float(60).radian
        zNear = 1.0
        zFar = 100.0
    }

}
