//
//  GIRRenderer.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import Foundation
import MetalKit


class GIRRenderer: NSObject, MTKViewDelegate {

    var device: MTLDevice?
    var scene: GIRScene?
    var nextFrameTime: CFTimeInterval
    var renderPipelineState: MTLRenderPipelineState!
    var samplerState: MTLSamplerState!
    var depthStencilState: MTLDepthStencilState!
    let commandQueue: MTLCommandQueue!
    var aspectRatio: Float = 1
    var pointOfView: GIRNode

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

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

        aspectRatio = Float(size.width / size.height)
    }

    func draw(in view: MTKView) {
        aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        guard let passDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable else {
            debugPrint("currentRenderPassDescriptor, drawable error")
            return
        }

        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0)

        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            return
        }

        commandEncoder.setCullMode(.back)
        commandEncoder.setFrontFacing(.counterClockwise)
        commandEncoder.setDepthStencilState(depthStencilState!)
        commandEncoder.setRenderPipelineState(renderPipelineState!)
        drawScene(commandEncoder: commandEncoder)
        commandEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func drawScene(commandEncoder: MTLRenderCommandEncoder) {
        drawNode(scene?.rootNode, commandEncoder: commandEncoder, parent: nil)
    }

    func createUniformBuffer() -> MTLBuffer {
        let uniformDataLength = MemoryLayout<matrix_float4x4>.stride
        return (device?.makeBuffer(length: uniformDataLength, options: []))!
    }

    func updateNodeView(_ node: GIRNode, parent: GIRNode?, uniformBuffer: MTLBuffer) {
        let viewMatrix = Matrix4.translationMatrix(float3(x: 0.0, y: 0.0, z: -10))

        var modelMatrix = node.transform
        if let parent = parent {
            modelMatrix = parent.transform * modelMatrix
        }

        var projectionMatrix: float4x4 = float4x4()

        if let camera = pointOfView.camera {
            // only recalculate when camera spec changed
            if camera.shouldUpdateProjMatrix {
                projectionMatrix = Matrix4.perspective(fovy: Float(camera.fieldOfView).radian, aspect: aspectRatio, nearZ: camera.zNear, farZ: camera.zFar)
                camera.projectionMatrix = projectionMatrix
            } else {
                projectionMatrix = camera.projectionMatrix
            }
        } else {
            projectionMatrix = Matrix4.perspective(fovy: Float(29).radian, aspect: aspectRatio, nearZ: 0, farZ: 200)
        }

        let modelViewProjectionMatrix = simd_mul(projectionMatrix, simd_mul(viewMatrix, node.transform))

        let bufferPointer = uniformBuffer.contents()
        var uniforms = GIRUniforms(modelViewProjectionMatrix: modelViewProjectionMatrix)
        memcpy(bufferPointer, &uniforms, MemoryLayout<GIRUniforms>.size)
    }

    func drawNode(_ node: GIRNode?, commandEncoder: MTLRenderCommandEncoder, parent: GIRNode?) {
        guard let node = node else {
            return
        }

        let uniformBuffer = createUniformBuffer()
        updateNodeView(node, parent: parent, uniformBuffer: uniformBuffer)
        
        var fragmentUniforms = GIRFragmentUniforms()
        
        if let material = node.geometry?.materials.first {
            commandEncoder.setFragmentTexture(material.albedoTexture, index: 0)
            if let samplerState = samplerState {
                commandEncoder.setFragmentSamplerState(samplerState, index: 0)
            }
            
            fragmentUniforms.matAmbient = material.ambient
            fragmentUniforms.matDiffuse = material.diffuse
            fragmentUniforms.matSpecular = material.specular
            fragmentUniforms.matShininess = material.shininess
        }
        
        commandEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<GIRFragmentUniforms>.size, index: 0)

        if let mesh = node.geometry?.mesh {
            drawMesh(mesh, commandEncoder: commandEncoder, uniformBuffer: uniformBuffer)
        }

        for child in node.children {
            drawNode(child, commandEncoder: commandEncoder, parent: node)
        }
    }

    func drawMesh(_ mesh: MTKMesh, commandEncoder: MTLRenderCommandEncoder, uniformBuffer: MTLBuffer) {
        guard let vertexBuffer = mesh.vertexBuffers.first else {
            return
        }

        commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)

        for submesh in mesh.submeshes {
            commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                 indexCount: submesh.indexCount,
                                                 indexType: submesh.indexType,
                                                 indexBuffer: submesh.indexBuffer.buffer,
                                                 indexBufferOffset: submesh.indexBuffer.offset)
        }
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
