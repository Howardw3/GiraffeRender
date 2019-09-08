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
    enum DrawMode {
        case geometry
        case shadow
        case cubemap
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        aspectRatio = Float(size.width / size.height)

        createShadowTexture(width: Int(size.width), height: Int(size.height))
        createShadowPipelineState()
        createShadowPassDescriptor()
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

        guard let shadowCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: shadowPassDescriptor) else {
            debugPrint("shadow pass failed")
            return
        }

        shadowCommandEncoder.label = "Shadow pass"
        shadowCommandEncoder.setCullMode(.front)
        shadowCommandEncoder.setFrontFacing(.counterClockwise)
        shadowCommandEncoder.setRenderPipelineState(shadowPipelineState)
        shadowCommandEncoder.setDepthStencilState(depthStencilState)
        drawScene(commandEncoder: shadowCommandEncoder, isShadowMode: true)
        shadowCommandEncoder.endEncoding()

        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            return
        }

        if let backgrouandTexture = scene?.background._content.texture {
            commandEncoder.label = "Cubemap pass"
            commandEncoder.setCullMode(.back)
            commandEncoder.setFrontFacing(.counterClockwise)
            commandEncoder.setDepthStencilState(cubemapDepthStencilState!)
            commandEncoder.setRenderPipelineState(skyboxPipelineState!)
            drawCubemap(commandEncoder: commandEncoder, node: self.cubmapNode, texture: backgrouandTexture)
        }

        commandEncoder.label = "Main pass"
        commandEncoder.setDepthStencilState(depthStencilState!)
        commandEncoder.setRenderPipelineState(renderPipelineState!)
        drawScene(commandEncoder: commandEncoder)

        commandEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func drawCubemap(commandEncoder: MTLRenderCommandEncoder, node: GIRNode, texture: MTLTexture, ignorePosition: Bool = true) {
        var viewMatrix = pointOfView.transform.inverse

        if ignorePosition {
            viewMatrix.columns.3.x = 0
            viewMatrix.columns.3.y = 0
            viewMatrix.columns.3.z = 0
        }

        guard let cubemapMesh = node.geometry?.mesh, let submesh = cubemapMesh.submeshes.first, let vertexBuffer = cubemapMesh.vertexBuffers.first?.buffer else {
            return
        }

        let uniforms = GIRCubemapUniforms(projectionMatrix: getProjectionMatrix(), viewMatrix: viewMatrix)

        let uniformBuffer = cubemapBufferContainer.getNextAvailable(rawData: uniforms)
        commandEncoder.setFragmentTexture(texture, index: 0)
        commandEncoder.setFragmentSamplerState(envSamplerState!, index: 0)

        drawSubmesh(submesh, commandEncoder: commandEncoder, vertexBuffer: vertexBuffer, vertexUniformBuffer: uniformBuffer)
    }

    func drawScene(commandEncoder: MTLRenderCommandEncoder, isShadowMode: Bool = false) {
        drawNode(scene?.rootNode, commandEncoder: commandEncoder, parent: nil, isShadowMode: isShadowMode)
        shouldUpdateCamera = true
    }

    func drawNode(_ node: GIRNode?, commandEncoder: MTLRenderCommandEncoder, parent: GIRNode?, isShadowMode: Bool = false) {
        guard let node = node else {
            return
        }
        updateLightsInScene(node: node)

        drawGeometry(node, parent: parent, commandEncoder: commandEncoder, shouldDrawTexture: !isShadowMode)

        for child in node.children {
            drawNode(child, commandEncoder: commandEncoder, parent: node, isShadowMode: isShadowMode)
        }
    }

    func drawGeometry(_ node: GIRNode, parent: GIRNode?, commandEncoder: MTLRenderCommandEncoder, shouldDrawTexture: Bool = true) {
        guard let mesh = node.geometry?.mesh, let vertexBuffer = mesh.vertexBuffers.first else {
            return
        }

        for i in 0..<mesh.submeshes.count {
            let submesh = mesh.submeshes[i]
            var uniformBuffer: MTLBuffer!

            if shouldDrawTexture {
                let material = node.geometry!.materials[i]
                uniformBuffer = vertexBufferContainer.getNextAvailable()

                updateModelViewProj(node, parent: parent, uniformBuffer: uniformBuffer)
                setMaterialTextureAndUniforms(material: material, commandEncoder: commandEncoder)
                copyLightMemory(node: node, commandEncoder: commandEncoder)
                setShadowTexture(commandEncoder: commandEncoder)
                setCubeMapTexture(commandEncoder: commandEncoder)
                setLightMapTexture(commandEncoder: commandEncoder)

                commandEncoder.setFragmentSamplerState(nearestSamplerState!, index: PRBSamplerStateIndexNearest.raw)
                commandEncoder.setFragmentSamplerState(linearSamplerState!, index: PRBSamplerStateIndexLinear.raw)
                commandEncoder.setFragmentSamplerState(envSamplerState, index: PRBSamplerStateIndexEnv.raw)
            } else {
                uniformBuffer = createShadowUniformsBuffer(node: node)
            }

            drawSubmesh(submesh, commandEncoder: commandEncoder, vertexBuffer: vertexBuffer.buffer, vertexUniformBuffer: uniformBuffer)
        }
    }

    func drawSubmesh(_ submesh: MTKSubmesh, commandEncoder: MTLRenderCommandEncoder, vertexBuffer: MTLBuffer, vertexUniformBuffer: MTLBuffer) {

        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(vertexUniformBuffer, offset: 0, index: 1)

        commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                             indexCount: submesh.indexCount,
                                             indexType: submesh.indexType,
                                             indexBuffer: submesh.indexBuffer.buffer,
                                             indexBufferOffset: submesh.indexBuffer.offset)
    }
}

extension GIRRenderer {
    func setCubeMapTexture(commandEncoder: MTLRenderCommandEncoder) {
        if let backgrouandTexture = scene?.background._content.texture {
            commandEncoder.setFragmentTexture(backgrouandTexture, index: PBRTexIndexEnvironment.raw)
        }
    }

    func setLightMapTexture(commandEncoder: MTLRenderCommandEncoder) {
        if let lightmapTexture = scene?.lightingEnvironment._content.texture {
            commandEncoder.setFragmentTexture(lightmapTexture, index: PBRTexIndexIrradiance.raw)
        }
    }

    func setShadowTexture(commandEncoder: MTLRenderCommandEncoder) {
        commandEncoder.setFragmentTexture(shadowTexture, index: 0)
    }

    func createShadowUniformsBuffer(node: GIRNode) -> MTLBuffer {
        let lightSpaceMatrix = calculateLightSpaceMatrix(node: node)
        let shadowUniform = GIRShadowUniforms(modelMatrix: node.transform, lightSpaceMatrix: lightSpaceMatrix)
        return shadowBufferContainer.getNextAvailable(rawData: shadowUniform)
    }

    // only support one light for now
    func calculateLightSpaceMatrix(node: GIRNode) -> float4x4 {
        if let light = lightsInScene.first {
//            let lightProjection = float4x4.perspective(fovy: Float(29).radian, aspect: aspectRatio, nearZ: 0.1, farZ: 100.0)
            let lightProjection = float4x4.orthoMatrix(left: -10, right: 10, bottom: -10, top: 10, nearZ: -40, farZ: 40)
            let lookatMatrix = float4x4.lookatMatrix(eye: light.value.raw.position, center: -light.value.raw.position, up: float3(0, 1, 0))
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
        let lightBuffer = lightBufferContainer.getNextAvailable()
        commandEncoder.setFragmentBuffer(lightBuffer, offset: 0, index: PBRFragBufIndexLight.raw)

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

    func setMaterialTextureAndUniforms(material: GIRMaterial, commandEncoder: MTLRenderCommandEncoder) {

        let data = material.pbrData
        commandEncoder.setFragmentTextures(data.textures, range: PBRTexIndexTextures.raw..<data.textures.count + PBRTexIndexTextures.raw)

        var fragmentUniforms = GIRFragmentUniforms()
        fragmentUniforms.cameraPosition = pointOfView.position
        fragmentUniforms.matShininess = material.shininess
        fragmentUniforms.colorTypes = data.colorTypes
        fragmentUniforms.colors = data.colors

        let buffer = materialBufferContainer.getNextAvailable(rawData: fragmentUniforms.raw)
        commandEncoder.setFragmentBuffer(buffer, offset: 0, index: PBRFragBufIndexFragment.raw)
    }

    func updateModelViewProj(_ node: GIRNode, parent: GIRNode?, uniformBuffer: MTLBuffer) {
        let viewMatrix = pointOfView.transform.inverse

        var modelMatrix = node.transform
        if let parent = parent {
            modelMatrix = parent.transform * modelMatrix
        }

        let projectionMatrix = getProjectionMatrix()
        let viewProjectionMatrix = projectionMatrix * viewMatrix

        let normalMatirx = float3x3(modelMatrix[0].xyz, modelMatrix[1].xyz, modelMatrix[2].xyz).transpose.inverse
        var uniforms = GIRVertexUniforms(viewProjectionMatrix: viewProjectionMatrix, modelMatrix: node.transform, normalMatrix: normalMatirx, lightSpaceMatrix: calculateLightSpaceMatrix(node: node))
        memcpy(uniformBuffer.contents(), &uniforms, MemoryLayout<GIRVertexUniforms>.size)
    }

    func getProjectionMatrix() -> float4x4 {
        var projectionMatrix: float4x4!

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
            projectionMatrix = float4x4.perspective(fovy: Float(29).radian, aspect: aspectRatio, nearZ: 1, farZ: 200)
        }

        return projectionMatrix
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
