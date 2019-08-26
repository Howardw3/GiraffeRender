//
//  GIRRenderer+MTKViewDelegate.swift
//  GiraffeRender
//
//  Created by Jiongzhi Wang on 8/22/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import simd
import MetalKit
extension GIRRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        aspectRatio = Float(size.width / size.height)
    }

    func draw(in view: MTKView) {
        aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        guard let shadowCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: shadowPassDescriptor) else {
            debugPrint("shadow pass failed")
            return
        }
        shadowCommandEncoder.setCullMode(.back)
        shadowCommandEncoder.setFrontFacing(.counterClockwise)
        shadowCommandEncoder.setRenderPipelineState(shadowPipelineState)
        shadowCommandEncoder.setDepthStencilState(depthStencilState)
        drawScene(commandEncoder: shadowCommandEncoder, isShadowMode: true)
        shadowCommandEncoder.endEncoding()

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

    func drawScene(commandEncoder: MTLRenderCommandEncoder, isShadowMode: Bool = false) {
        drawNode(scene?.rootNode, commandEncoder: commandEncoder, parent: nil, isShadowMode: isShadowMode)
        shouldUpdateCamera = true
    }
    
    func updateModelViewProj(_ node: GIRNode, parent: GIRNode?, uniformBuffer: MTLBuffer) {
        let viewMatrix = pointOfView.transform.inverse

        var modelMatrix = node.transform
        if let parent = parent {
            modelMatrix = parent.transform * modelMatrix
        }

        var projectionMatrix: float4x4 = float4x4()

        if let camera = pointOfView.camera {
            // only recalculate when camera spec changed
            if camera.shouldUpdateProjMatrix || shouldUpdateCamera {
                projectionMatrix = float4x4.perspective(fovy: Float(camera.fieldOfView).radian, aspect: aspectRatio, nearZ: camera.zNear, farZ: camera.zFar)
                camera.projectionMatrix = projectionMatrix
                shouldUpdateCamera = false
            } else {
                projectionMatrix = camera.projectionMatrix
            }
        } else {
            projectionMatrix = float4x4.perspective(fovy: Float(29).radian, aspect: aspectRatio, nearZ: 0, farZ: 200)
        }

        let viewProjectionMatrix = projectionMatrix * viewMatrix
        let normalMatirx = float3x3(modelMatrix[0].xyz, modelMatrix[1].xyz, modelMatrix[2].xyz).transpose.inverse
        var uniforms = GIRVertexUniforms(viewProjectionMatrix: viewProjectionMatrix, modelMatrix: node.transform, normalMatrix: normalMatirx, lightSpaceMatrix: calculateLightSpaceMatrix(node: node))
        memcpy(uniformBuffer.contents(), &uniforms, MemoryLayout<GIRVertexUniforms>.size)
    }

    func drawNode(_ node: GIRNode?, commandEncoder: MTLRenderCommandEncoder, parent: GIRNode?, isShadowMode: Bool = false) {
        guard let node = node else {
            return
        }
        updateLightsInScene(node: node)
        
        var uniformBuffer: MTLBuffer!
        if !isShadowMode {
            uniformBuffer = createUniformBuffer()
            updateModelViewProj(node, parent: parent, uniformBuffer: uniformBuffer)
            copyMaterialMemory(node: node, commandEncoder: commandEncoder)
            copyLightMemory(node: node, commandEncoder: commandEncoder)
            setShadowTexture(commandEncoder: commandEncoder)
        } else {
            uniformBuffer = createShadowUniformsBuffer(node: node)
        }

        if let mesh = node.geometry?.mesh {
            drawMesh(mesh, commandEncoder: commandEncoder, uniformBuffer: uniformBuffer)
        }

        for child in node.children {
            drawNode(child, commandEncoder: commandEncoder, parent: node)
        }
    }

    func setShadowTexture(commandEncoder: MTLRenderCommandEncoder) {
        commandEncoder.setFragmentTexture(shadowTexture, index: 0)
    }

    func createShadowUniformsBuffer(node: GIRNode) -> MTLBuffer {
        let uniformDataLength = MemoryLayout<GIRShadowUniforms>.size
        let buffer = (device?.makeBuffer(length: uniformDataLength, options: []))!
        let lightSpaceMatrix = calculateLightSpaceMatrix(node: node)
        var shadowUniform = GIRShadowUniforms(modelMatrix: node.worldTransform, lightSpaceMatrix: lightSpaceMatrix)
        memcpy(buffer.contents(), &shadowUniform, uniformDataLength)
        return buffer
    }

    // only support one light for now
    func calculateLightSpaceMatrix(node: GIRNode) -> float4x4 {
        if let light = lightsInScene.first {
            let lightProjection = float4x4.perspective(fovy: Float(50).radian, aspect: aspectRatio, nearZ: 1.0, farZ: 200.0)
            let lookatMatrix = float4x4.lookatMatrix(eye: -light.value.raw.position, center:-light.value.raw.position, up: light.value.up)
            let lightSpaceMatirx = lightProjection * lookatMatrix
            return lightSpaceMatirx
        }
        return float4x4()
    }

    func updateLightsInScene(node: GIRNode?) {
        guard let node = node, let light = node.light else {
            return
        }

        lightsInScene[light.name] = LightInfo(raw: GIRLight.LightRaw(type: light.type.rawValue, position: node.position, direction: node.localFront, color: light.convertedColor, intensity: light.intensity), up: node.localUp)
    }

    // the first frame will skip lighting
    func copyLightMemory(node: GIRNode, commandEncoder: MTLRenderCommandEncoder) {
        // TODO: should use buffer pool
        let lightBuffer = (device?.makeBuffer(length: GIRLight.LightRaw.length, options: []))!
        commandEncoder.setFragmentBuffer(lightBuffer, offset: 0, index: 1)

        if lightsInScene.isEmpty {
            var lightRaw = GIRLight.LightRaw()
            memcpy(lightBuffer.contents(), &lightRaw, GIRLight.LightRaw.length)
            return
        }

        for (_, light) in lightsInScene {
            var light = light
            memcpy(lightBuffer.contents(), &light, GIRLight.LightRaw.length)
        }
    }

    func copyMaterialMemory(node: GIRNode, commandEncoder: MTLRenderCommandEncoder) {
        var fragmentUniforms = GIRFragmentUniforms()
        fragmentUniforms.cameraPosition = pointOfView.position
        if let material = node.geometry?.material {

//            commandEncoder.setFragmentTexture(material.data.textures, index: 0)
            commandEncoder.setFragmentTextures(material.data.textures, range: 1..<material.data.textures.count + 1)
            if let samplerState = samplerState {
                commandEncoder.setFragmentSamplerState(samplerState, index: 0)
            }

//            fragmentUniforms.matAmbient = material.ambient
//            fragmentUniforms.matDiffuse = material.diffuse
//            fragmentUniforms.matSpecular = material.specular
            fragmentUniforms.matShininess = material.shininess
        }

        let framgentUniformBuffer = (device?.makeBuffer(length: GIRFragmentUniforms.length, options: []))!
        var fragmentUniformsRaw = fragmentUniforms.raw
        commandEncoder.setFragmentBuffer(framgentUniformBuffer, offset: 0, index: 0)
        let bufferPointer = framgentUniformBuffer.contents()
        memcpy(bufferPointer, &fragmentUniformsRaw, GIRFragmentUniforms.length)
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
}
