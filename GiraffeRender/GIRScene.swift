//
//  GIRScene.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import Foundation

open class GIRScene {
    public var rootNode: GIRNode
    public var pointOfView: GIRNode
    public var background: GIRMaterialProperty

    public init() {
        rootNode = GIRNode()
        pointOfView = GIRNode()
        pointOfView.camera = GIRCamera()
        background = GIRMaterialProperty()
    }
}
