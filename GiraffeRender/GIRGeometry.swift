//
//  Geometry.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd
import MetalKit

open class GIRGeometry {
    var mesh: MTKMesh

    init(mesh: MTKMesh) {
        self.mesh = mesh
    }
}
