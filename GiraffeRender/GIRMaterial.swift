//
//  GIRMaterial.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/12/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import Foundation

public class GIRMaterial {
    public var albedoTexture: MTLTexture
    init(texture: MTLTexture) {
        albedoTexture = texture
    }
}
