//
//  GIRMaterial.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/12/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import Foundation
import simd

public class GIRMaterial {
//    enum MType: String {
//        case albedo
//        case diffuse
//        case ambient
//        case specular
//    }
//    var dict: [MType: Content] = [:]
//
//    func get(type: MType) -> Any? {
//
//    }
//    public var albedo: GIRMaterialProperty {
//        get {
//            return getDict(type: .albedo)
//        }
//        set(newVal) {
//            if let val = newVal {
//
//            }
//        }
//    }
    public var albedo: GIRMaterialProperty
    public var diffuse: GIRMaterialProperty
    public var ambient: GIRMaterialProperty
    public var specular: GIRMaterialProperty
    public var shininess: Float

    init() {
        albedo = GIRMaterialProperty()
        diffuse = GIRMaterialProperty()
        ambient = GIRMaterialProperty()
        specular = GIRMaterialProperty()
        shininess = 1.0
    }
}
