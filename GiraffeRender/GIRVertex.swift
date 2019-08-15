//
//  Vertex.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd

struct GIRVertex {
    static let length = MemoryLayout<Float>.size * 8

    var position: float3
    var coordnates: float2
    var normal: float3

    init(pos: float3, coord: float2, normal: float3) {
        self.position = pos
        self.coordnates = coord
        self.normal = normal
    }
}
