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
    float4x4 model_view_proj_matrix;
};

struct VertexIn {
    packed_float3 position;
    packed_float2 tex_coord;
    packed_float3 normal;
};

struct VertexOut {
    float4 position [[ position ]];
    float2 tex_coord;
    float3 normal;
};

struct FragmentIn {
    packed_float3 light_color;
    packed_float3 light_pos;
    packed_float3 mat_diffuse;
    packed_float3 mat_specular;
    packed_float3 mat_ambient;
    packed_float3 mat_shininess;
};

vertex VertexOut basic_vertex(constant VertexIn* vertex_array [[ buffer(0) ]],
                           constant Uniforms& uniforms [[ buffer(1) ]],
                           uint vid [[ vertex_id ]]) {
    VertexIn vertex_in = vertex_array[vid];
    
    VertexOut vertex_out;
    vertex_out.position = uniforms.model_view_proj_matrix * float4(vertex_in.position, 1);
    vertex_out.tex_coord = vertex_in.tex_coord;
    vertex_out.normal = vertex_in.normal;
    
    return vertex_out;
}

fragment float4 basic_fragment(VertexOut frag_in [[ stage_in ]],
                               texture2d<float> texture2D [[ texture(0) ]],
                               sampler sampler2D [[ sampler(0) ]],
                               constant FragmentIn &uniforms [[ buffer(0) ]]) {
    float4 texture = texture2D.sample(sampler2D, frag_in.tex_coord);
//    float3 lightColor = float4(uniforms.lightColor, 1);
//    float4 color = float4(uniforms.light_color, 1) * texture;
    float3 color = float3(1.0f, 0.5f, 0.31f);
    float3 obj_pos = float3(frag_in.position[0], frag_in.position[1], frag_in.position[2]);
    float ambient_intensity = 1.f;
    float specular_intensity = 0.3f;
    // ambient
    float3 ambient = ambient_intensity * uniforms.light_color * uniforms.mat_ambient;
    
    // diffuse
    float3 norm = normalize(frag_in.normal);
    float3 light_dir = normalize(uniforms.light_pos - obj_pos);
    float diff = max(dot(norm, float3(uniforms.light_pos)), 0.0f);
    float3 diffuse = uniforms.light_color * (diff * uniforms.mat_diffuse);
    
    // specular
    float3 camera_pos = float3(0.0f, 0.0f, 0.0f);
    float3 view_dir = normalize(camera_pos - obj_pos);
    float3 reflect_dir = reflect(-light_dir, norm);
    float spec = pow(max(dot(view_dir, reflect_dir), 0.0f), 32);
    float3 specular = specular_intensity * spec * uniforms.light_color;
    
    color = ambient * diffuse/diffuse * specular/specular * color;
    
    float4 final_color = float4(color, 1.0f);
    return final_color;
}

vertex Vertex cube_vertex(constant Vertex *vertices [[buffer(0)]],
                          constant Uniforms &uniforms [[buffer(1)]],
                          uint vid [[vertex_id]]){
    float4x4 matrix = uniforms.model_view_proj_matrix;
    Vertex in = vertices[vid];
    Vertex out;

    out.position = matrix * float4(in.position);
    out.color = in.color;

    return out;
}

fragment half4 cube_fragment(Vertex vert [[stage_in]]){
    return half4(vert.color);
}
