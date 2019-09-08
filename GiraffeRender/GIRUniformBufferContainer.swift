//
//  GIRUniformBufferContainer.swift
//  GiraffeRender
//
//  Created by Howard Wang on 9/7/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import MetalKit

class GIRUniformBufferContainer {
    static let maxInflightBuffers: Int = 3
    private let inflightSemaphore: DispatchSemaphore
    private var currIndex: Int
    private var buffers: [MTLBuffer]
    private let length: Int
    private let maxCount: Int

    init(device: MTLDevice, length: Int, maxCount: Int = GIRUniformBufferContainer.maxInflightBuffers) {
        self.inflightSemaphore = DispatchSemaphore(value: maxCount)
        self.buffers = [MTLBuffer]()
        self.currIndex = 0
        self.length = length
        self.maxCount = maxCount

        for _ in 0..<maxCount {
            if let buffer = device.makeBuffer(length: length, options: []) {
                buffers.append(buffer)
            }
        }

        assert(buffers.count == maxCount, "Create uniform buffer failed")
    }

    func getNextAvailable<T>(rawData: [T]) -> MTLBuffer {
        let buffer = getNextAvailable()

        var rawData = rawData
        let bufferPointer = buffer.contents()
        memcpy(bufferPointer, &rawData, length)

        return buffer
    }

    func getNextAvailable<T>(rawData: T) -> MTLBuffer {
        let buffer = getNextAvailable()

        var rawData = rawData
        let bufferPointer = buffer.contents()
        memcpy(bufferPointer, &rawData, length)

        return buffer
    }

    func getNextAvailable() -> MTLBuffer {
        let buffer = buffers[currIndex]

        currIndex += 1
        if currIndex == maxCount {
            currIndex = 0
        }

        return buffer
    }
}
