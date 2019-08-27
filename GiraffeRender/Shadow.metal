//
//  Shadow.metal
//  GiraffeRender
//
//  Created by Howard Wang on 8/26/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    packed_float3 position;
    packed_float3 normal;
    packed_float3 tangent;
    packed_float2 tex_coord;
};

struct ShadowUniform {
    float4x4 model_matrix;
    float4x4 light_space_matrix;
};

vertex float4
shadow_vertex(constant VertexIn* vertex_array [[ buffer(0) ]],
              constant ShadowUniform& uniforms [[ buffer(1) ]],
              uint vid [[ vertex_id ]])
{
    VertexIn vertex_in = vertex_array[vid];
    return uniforms.light_space_matrix * uniforms.model_matrix * float4(vertex_in.position, 1.0f);
}
