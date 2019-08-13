//
//  GIRMaterial.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/12/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import Foundation

public class GIRMaterial {
    public var baseColorTexture: MTLTexture
    init(texture: MTLTexture) {
        baseColorTexture = texture
    }
}
