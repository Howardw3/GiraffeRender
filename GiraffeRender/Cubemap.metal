//
//  Cubemap.metal
//  GiraffeRender
//
//  Created by Howard Wang on 8/29/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexUniforms {
    float4x4 projection;
    float4x4 view;
};

struct VertexIn {
    packed_float3 position;
    packed_float3 normal;
    packed_float3 tangent;
    packed_float2 tex_coord;
};

struct VertexOut {
    float4 position [[position]];
    float3 tex_coord;
};

vertex VertexOut
cubemap_vertex(constant VertexIn *vertex_in [[ buffer(0) ]],
               constant VertexUniforms& uniforms [[ buffer(1) ]],
               uint vid [[ vertex_id ]])
{
    VertexIn in = vertex_in[vid];

    VertexOut out;
    out.position = uniforms.projection * uniforms.view * float4(in.position, 1.0f);
    out.tex_coord = in.position;

    return out;
}

fragment float4
cubemap_fragment(VertexOut frag_in [[ stage_in ]],
                 texturecube<float> skybox_texture2D [[texture(0)]],
                 sampler sampler2D [[ sampler(0) ]])
{
    float4 texture = skybox_texture2D.sample(sampler2D, frag_in.tex_coord);

    return texture;
}
