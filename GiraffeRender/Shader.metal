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

struct VertexUniforms {
    float4x4 view_proj_matrix;
    float4x4 model_matrix;
};

struct VertexIn {
    packed_float3 position;
    packed_float2 tex_coord;
    packed_float3 normal;
};

struct VertexOut {
    float4 position [[ position ]];
    float2 tex_coord;
    float3 frag_world_normal;
    float3 frag_world_pos;
};

struct FragmentUniforms {
    packed_float3 camera_pos;
    packed_float3 light_color;
    packed_float3 light_pos;
    packed_float3 mat_diffuse;
    packed_float3 mat_specular;
    packed_float3 mat_ambient;
    float mat_shininess;
};

vertex VertexOut basic_vertex(constant VertexIn* vertex_array [[ buffer(0) ]],
                           constant VertexUniforms& uniforms [[ buffer(1) ]],
                           uint vid [[ vertex_id ]]) {
    VertexIn vertex_in = vertex_array[vid];
    
    float4 model_world_pos = uniforms.model_matrix * float4(vertex_in.position, 1);
    VertexOut vertex_out;
    vertex_out.position = uniforms.view_proj_matrix * model_world_pos;
    vertex_out.frag_world_pos = model_world_pos.xyz;
    vertex_out.tex_coord = vertex_in.tex_coord;
    vertex_out.frag_world_normal = (uniforms.model_matrix * float4(vertex_in.normal, 1.0)).xyz;
    
    return vertex_out;
}

fragment float4 basic_fragment(VertexOut frag_in [[ stage_in ]],
                               texture2d<float> texture2D [[ texture(0) ]],
                               sampler sampler2D [[ sampler(0) ]],
                               constant FragmentUniforms &uniforms [[ buffer(0) ]]) {
    float4 texture = texture2D.sample(sampler2D, frag_in.tex_coord);
    
    float3 color = float3(1.0f, 0.5f, 0.31f);
    float ambient_intensity = 0.6f;
    float diffuse_intensity = 0.6f;
    float specular_intensity = 1.0f;

    float3 norm = normalize(frag_in.frag_world_normal);
    // ambient
    float3 ambient = ambient_intensity * uniforms.light_color * uniforms.mat_ambient;
    
    // diffuse
    float3 light_dir = normalize(uniforms.light_pos - frag_in.frag_world_pos);
    float diffuse_factor = max(dot(norm, light_dir), 0.0f);
    float3 diffuse = diffuse_factor * diffuse_intensity * uniforms.light_color * uniforms.mat_diffuse;
    
    // specular
    float3 camera_pos = -uniforms.camera_pos;
    float3 view_dir = normalize(camera_pos - frag_in.frag_world_pos);
    float3 reflect_dir = reflect(-light_dir, norm);
    float specular_factor = pow(max(dot(view_dir, reflect_dir), 0.0f), uniforms.mat_shininess);
    float3 specular = specular_factor * specular_intensity * uniforms.light_color;
    
    color = ambient + diffuse + specular;
//    color = float3(norm.x, norm.y, norm.z);
    float4 final_color = float4(color, 1.0f) * texture;
    return final_color;
}
