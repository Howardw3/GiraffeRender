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
    var rps: MTLRenderPipelineState?
    let commandQueue: MTLCommandQueue!
    var aspectRatio: Float = 1
    var pointOfView: GIRNode
    var samplerState: MTLSamplerState?

    init(device: MTLDevice?) {
        self.device = device
        self.nextFrameTime = 0
        self.commandQueue = device?.makeCommandQueue()
        self.pointOfView = GIRNode()
        self.pointOfView.camera = GIRCamera()
        super.init()

        registerShaders()
        buildSamplerState(device: device!)
    }

    func registerShaders() {
        guard let library = device?.makeDefaultLibrary() else {
            return
        }

        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = library.makeFunction(name: "basic_vertex")
        rpld.fragmentFunction = library.makeFunction(name: "basic_fragment")
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            try rps = device?.makeRenderPipelineState(descriptor: rpld)
        } catch let error {
            debugPrint(error)
        }
    }

    func buildSamplerState(device: MTLDevice) {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)!
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
            debugPrint("rpd, drawable error")
            return
        }

        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0)

        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            return
        }

        commandEncoder.setRenderPipelineState(rps!)
        commandEncoder.setCullMode(.front)

        drawScene(commandEncoder: commandEncoder)
        commandEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func drawScene(commandEncoder: MTLRenderCommandEncoder) {
        drawNode(scene?.rootNode, commandEncoder: commandEncoder, parent: nil)
    }

    func createUniformBuffer() -> MTLBuffer {
        let uniformDataLength = MemoryLayout<matrix_float4x4>.stride * 2
        return (device?.makeBuffer(length: uniformDataLength, options: []))!
    }

    func updateNodeView(_ node: GIRNode, parent: GIRNode?, uniformBuffer: MTLBuffer) {
        let viewMatrix = Matrix4.translationMatrix(float3(x: 0.0, y: 0.0, z: -3))

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

        if let material = node.geometry?.materials.first {
            commandEncoder.setFragmentTexture(material.baseColorTexture, index: 0)
            if let samplerState = samplerState {
                commandEncoder.setFragmentSamplerState(samplerState, index: 0)
            }
        }

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
            commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
        }
    }
}
