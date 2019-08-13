//
//  Shader.metal
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelViewProjMatrix;
};

struct VertexIn {
    packed_float3 position;
    packed_float2 texCoord;
};

struct VertexOut {
    float4 position [[ position ]];
    float2 texCoord;
};

vertex VertexOut basic_vertex(constant VertexIn* vertex_array [[ buffer(0) ]],
                           constant Uniforms& uniforms [[ buffer(1) ]],
                           uint vid [[ vertex_id ]]) {
    VertexIn vertex_in = vertex_array[vid];
    
    VertexOut vertex_out;
    vertex_out.position = uniforms.modelViewProjMatrix * float4(vertex_in.position, 1);
    vertex_out.texCoord = vertex_in.texCoord;
    
    return vertex_out;
}

fragment float4 basic_fragment(VertexOut interpolated [[ stage_in ]],
                               texture2d<float> texture2D [[ texture(0) ]],
                               sampler sampler2D [[ sampler(0) ]]) {
    float4 color = texture2D.sample(sampler2D, interpolated.texCoord);
    return color;
}

vertex Vertex cube_vertex(constant Vertex *vertices [[buffer(0)]],
                          constant Uniforms &uniforms [[buffer(1)]],
                          uint vid [[vertex_id]]){
    float4x4 matrix = uniforms.modelViewProjectionMatrix;
    Vertex in = vertices[vid];
    Vertex out;

    out.position = matrix * float4(in.position);
    out.color = in.color;

    return out;
}

fragment half4 cube_fragment(Vertex vert [[stage_in]]){
    return half4(vert.color);
}
