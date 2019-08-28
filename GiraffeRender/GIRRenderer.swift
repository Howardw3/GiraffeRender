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
    var shadowPipelineState: MTLRenderPipelineState!
    var shadowTexture: MTLTexture!
    var shadowPassDescriptor: MTLRenderPassDescriptor!
    var defaultLibrary: MTLLibrary!
    var samplerState: MTLSamplerState!
    var depthStencilState: MTLDepthStencilState!
    let commandQueue: MTLCommandQueue!
    var aspectRatio: Float = 1
    var pointOfView: GIRNode
    var shouldUpdateCamera = false
    var lightsInScene: [String: LightInfo] = [:]

    init(device: MTLDevice?) {
        self.device = device
        self.nextFrameTime = 0
        self.commandQueue = device?.makeCommandQueue()
        self.pointOfView = GIRNode()
        self.pointOfView.camera = GIRCamera()
        super.init()

        self.defaultLibrary = device?.makeDefaultLibrary()
        createSamplerState()
        createDepthStencilState()
        createRenderPipelineState()
        createShadowTexture(width: 1330, height: 700)
        createShadowPipelineState()
        createShadowPassDescriptor()
    }

    func createUniformBuffer() -> MTLBuffer {
        let uniformDataLength = MemoryLayout<GIRVertexUniforms>.size
        return (device?.makeBuffer(length: uniformDataLength, options: []))!
    }

    func createRenderPipelineState() {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = defaultLibrary.makeFunction(name: "basic_vertex")
        renderPipelineDescriptor.fragmentFunction = defaultLibrary.makeFunction(name: "basic_fragment")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        do {
            try renderPipelineState = device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch let error {
            debugPrint(error)
        }
    }

    func createShadowPipelineState() {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = defaultLibrary.makeFunction(name: "shadow_vertex")
        renderPipelineDescriptor.fragmentFunction = nil
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .invalid
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        do {
            try shadowPipelineState = device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch let error {
            debugPrint(error)
        }
    }

    func createShadowTexture(width: Int, height: Int) {
        let shadowTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: width, height: height, mipmapped: false)
        shadowTextureDescriptor.usage = [.shaderRead, .renderTarget]
        shadowTexture = device?.makeTexture(descriptor: shadowTextureDescriptor)
    }

    func createShadowPassDescriptor() {
        shadowPassDescriptor = MTLRenderPassDescriptor()
        guard let _ = shadowPassDescriptor else {
            return
        }

        shadowPassDescriptor.depthAttachment.texture = shadowTexture
        shadowPassDescriptor.depthAttachment.loadAction = .clear
        shadowPassDescriptor.depthAttachment.storeAction = .store
        shadowPassDescriptor.depthAttachment.clearDepth = 1.0
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

extension GIRRenderer {
    struct LightInfo {
        let raw: GIRLight.LightRaw
        let up: float3
    }
}
