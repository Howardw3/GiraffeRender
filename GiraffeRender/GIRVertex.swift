//
//  Vertex.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd

struct GIRVertex {
    static let count = 8
    static let size = MemoryLayout<Float>.size
    static let length = MemoryLayout<Float>.size * 8

    var position: float4
    var color: float4
    init(pos: float4, col: float4) {
        position = pos
        color = col
    }
}
