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
    var skyboxPipelineState: MTLRenderPipelineState!
    var hdrPipelineState: MTLRenderPipelineState!
    var shadowTexture: MTLTexture!
    var shadowPassDescriptor: MTLRenderPassDescriptor!
    var defaultLibrary: MTLLibrary!
    var linearSamplerState: MTLSamplerState!
    var nearestSamplerState: MTLSamplerState!
    var envSamplerState: MTLSamplerState!
    var depthStencilState: MTLDepthStencilState!
    var cubemapDepthStencilState: MTLDepthStencilState!
    let commandQueue: MTLCommandQueue!
    var aspectRatio: Float = 1

    var pointOfView: GIRNode
    var cubmapNode: GIRNode
    var hdrCubeNode: GIRNode
    var shouldUpdateCamera = false
    var lightsInScene: [String: LightInfo] = [:]

    var lightBufferContainer: GIRUniformBufferContainer!
    var materialBufferContainer: GIRUniformBufferContainer!
    var vertexBufferContainer: GIRUniformBufferContainer!
    var cubemapBufferContainer: GIRUniformBufferContainer!
    var shadowBufferContainer: GIRUniformBufferContainer!

    init(device: MTLDevice?) {
        self.device = device
        self.nextFrameTime = 0
        self.commandQueue = device?.makeCommandQueue()
        self.pointOfView = GIRNode()
        self.pointOfView.camera = GIRCamera()

        let cube = GIRGeometry(basic: .box(size: SIMD3<Float>(50, 50, 50), segments: [1, 1, 1], inward: true))
        self.cubmapNode = GIRNode(geometry: cube)

        let smallCube = GIRGeometry(basic: .box(size: SIMD3<Float>(6, 6, 6), segments: [1, 1, 1], inward: false))
        self.hdrCubeNode = GIRNode(geometry: smallCube)
        super.init()

        self.defaultLibrary = device?.makeDefaultLibrary()
        createLinearSamplerState()
        createNearestSamplerState()
        createEnvSamplerState()
        createDepthStencilState()
        createCubemapDepthStencilState()
        createRenderPipelineState()
        createShadowTexture(width: 1330, height: 700)
        createShadowPipelineState()
        createShadowPassDescriptor()
        createSkyboxPipelineState()
        createHDRPipelineState()

        createUniformBuffers()
    }

    func createUniformBuffers() {
        lightBufferContainer = GIRUniformBufferContainer(device: device!, length: GIRLight.LightRaw.length)
        materialBufferContainer = GIRUniformBufferContainer(device: device!, length: GIRFragmentUniforms.length)
        vertexBufferContainer = GIRUniformBufferContainer(device: device!, length: MemoryLayout<GIRVertexUniforms>.size)
        cubemapBufferContainer = GIRUniformBufferContainer(device: device!, length: MemoryLayout<GIRCubemapUniforms>.size)
        shadowBufferContainer = GIRUniformBufferContainer(device: device!, length: MemoryLayout<GIRShadowUniforms>.size)
    }

    func createSkyboxPipelineState() {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = defaultLibrary.makeFunction(name: "cubemap_vertex")
        renderPipelineDescriptor.fragmentFunction = defaultLibrary.makeFunction(name: "cubemap_fragment")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        do {
            try skyboxPipelineState = device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch let error {
            debugPrint(error)
        }
    }

    func createHDRPipelineState() {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = defaultLibrary.makeFunction(name: "hdr_vertex")
        renderPipelineDescriptor.fragmentFunction = defaultLibrary.makeFunction(name: "hdr_fragment")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        do {
            try hdrPipelineState = device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch let error {
            debugPrint(error)
        }
    }

    func createRenderPipelineState() {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = defaultLibrary.makeFunction(name: "pbr_vertex")
        renderPipelineDescriptor.fragmentFunction = defaultLibrary.makeFunction(name: "pbr_fragment")
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
#if targetEnvironment(macCatalyst)
        shadowTextureDescriptor.storageMode = .private
#endif
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

    func createLinearSamplerState() {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        linearSamplerState = device?.makeSamplerState(descriptor: samplerDescriptor)!
    }

    func createNearestSamplerState() {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .nearest
        samplerDescriptor.mipFilter = .nearest
        nearestSamplerState = device?.makeSamplerState(descriptor: samplerDescriptor)!
    }

    func createEnvSamplerState() {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge
        samplerDescriptor.rAddressMode = .clampToEdge
        envSamplerState = device?.makeSamplerState(descriptor: samplerDescriptor)!
    }

    func createDepthStencilState() {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilState = device?.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func createCubemapDepthStencilState() {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = false
        cubemapDepthStencilState = device?.makeDepthStencilState(descriptor: depthDescriptor)
    }
}

extension GIRRenderer {
    struct LightInfo {
        let raw: GIRLight.LightRaw
        let up: SIMD3<Float>
    }
}
