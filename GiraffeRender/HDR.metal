//
//  HDR.metal
//  GiraffeRender
//
//  Created by Howard Wang on 9/2/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexUniforms {
    float4x4 projection;
    float4x4 view;
};

struct VertexOut {
    float4 position [[position]];
    float3 tex_coord;
};

struct VertexIn {
    packed_float3 position;
    packed_float3 normal;
    packed_float3 tangent;
    packed_float2 tex_coord;
};

constant float2 invAtan = float2(0.1591, 0.3183);
float2 sample_spherical_map(float3 v)
{
    float2 uv = float2(atan2(v.z, v.x), asin(v.y));
    uv *= invAtan;
    uv += 0.5;
    return uv;
}

vertex VertexOut
hdr_vertex(constant VertexIn *vertex_in [[ buffer(0) ]],
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
hdr_fragment(VertexOut frag_in [[ stage_in ]],
                 texture2d<float> hdr_texture2D [[texture(0)]],
                 sampler sampler2D [[ sampler(0) ]])
{
    float2 tex_coord = sample_spherical_map(normalize(frag_in.tex_coord));
    float4 texture = hdr_texture2D.sample(sampler2D, tex_coord);

    return texture;
}
