//
//  GIRView.swift
//  GiraffeRender
//
//  Created by Howard Wang on 8/11/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

import MetalKit

open class GIRView: MTKView {
    private var renderer: GIRRenderer!

    open var scene: GIRScene? {
        didSet {
            if scene != nil {
                renderer.scene = scene
            }
        }
    }

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)

        setup()
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.device = MTLCreateSystemDefaultDevice()
        self.renderer = GIRRenderer(device: device)
        self.delegate = renderer

        let layer: CAMetalLayer = self.layer as! CAMetalLayer
        layer.framebufferOnly = false
        self.drawableSize.height = self.frame.height
        self.drawableSize.width = self.frame.width
        self.colorPixelFormat = .bgra8Unorm
        self.depthStencilPixelFormat = .invalid
    }
}
