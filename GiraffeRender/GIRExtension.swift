//
//  Extension.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import Foundation
public extension Float {
    var radian: Float {
        return self * .pi / 180
    }
}

extension PBRTextureIndex {
    var raw: Int {
        return Int(self.rawValue)
    }
}

extension PBRSamplerStateIndex {
    var raw: Int {
        return Int(self.rawValue)
    }
}

extension PBRFragBuferIndex {
    var raw: Int {
        return Int(self.rawValue)
    }
}

extension QualityLevel {
    var raw: Int {
        return Int(self.rawValue)
    }
}
