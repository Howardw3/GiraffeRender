//
//  Vertex.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd

struct GIRVertex {
    static let length = MemoryLayout<Float>.size * 5

    var position: float3
    var coordnates: float2

    init(pos: float3, coord: float2) {
        position = pos
        coordnates = coord
    }
}
