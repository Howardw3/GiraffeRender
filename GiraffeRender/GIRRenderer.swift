//
//  GIRRenderer.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import Foundation
import MetalKit

class GIRRenderer: NSObject {

    var device: MTLDevice?
    var scene: GIRScene?
    var nextFrameTime: CFTimeInterval
    var renderPipelineState: MTLRenderPipelineState!
    var samplerState: MTLSamplerState!
    var depthStencilState: MTLDepthStencilState!
    let commandQueue: MTLCommandQueue!
    var aspectRatio: Float = 1
    var pointOfView: GIRNode
    var shouldUpdateCamera = false
    var lightsInScene: [String: GIRLight.LightRaw] = [:]

    init(device: MTLDevice?) {
        self.device = device
        self.nextFrameTime = 0
        self.commandQueue = device?.makeCommandQueue()
        self.pointOfView = GIRNode()
        self.pointOfView.camera = GIRCamera()
        super.init()

        createSamplerState()
        createDepthStencilState()
        createRenderPipelineState()
    }

    func createUniformBuffer() -> MTLBuffer {
        let uniformDataLength = MemoryLayout<GIRVertexUniforms>.size
        return (device?.makeBuffer(length: uniformDataLength, options: []))!
    }

    func createRenderPipelineState() {
        guard let library = device?.makeDefaultLibrary() else {
            return
        }

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "basic_vertex")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "basic_fragment")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        do {
            try renderPipelineState = device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch let error {
            debugPrint(error)
        }
    }

    func createSamplerState() {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        samplerState = device?.makeSamplerState(descriptor: samplerDescriptor)!
    }

    func createDepthStencilState() {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilState = device?.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
}
