//
//  Shader.metal
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// Light const
constant int LIGHT_TYPE_AMBIENT = 0;
constant int LIGHT_TYPE_DIRECTIONAL = 1;
constant int LIGHT_TYPE_OMNI = 2;
constant int LIGHT_TYPE_SPOT = 3;

// Basic material type
enum BasicMaterial {
    albedo, diffuse, ambient, specular, normal
};

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct VertexUniforms {
    float4x4 view_proj_matrix;
    float4x4 model_matrix;
    float3x3 normal_matrix;
};

struct VertexIn {
    packed_float3 position;
    packed_float3 normal;
    packed_float3 tangent;
    packed_float2 tex_coord;
};

struct VertexOut {
    float4 position [[ position ]];
    float2 tex_coord;
    float3 frag_world_normal;
    float3 frag_world_pos;
    float3 tangent;
    float3 bitangent;
    float3 normal;
};

struct FragmentUniforms {
    packed_float3 camera_pos;
    packed_float3 mat_diffuse;
    packed_float3 mat_specular;
    packed_float3 mat_ambient;
    float mat_shininess;
};

struct Light {
    int2 type;
    packed_float3 position;
    packed_float3 direction;
    packed_float3 color;
    float intensity;
    float spot_inner_radian;
    float spot_outer_radian;
};

vertex VertexOut
basic_vertex(constant VertexIn* vertex_array [[ buffer(0) ]],
             constant VertexUniforms& uniforms [[ buffer(1) ]],
             uint vid [[ vertex_id ]]) {

    VertexIn vertex_in = vertex_array[vid];

    float4 model_world_pos = uniforms.model_matrix * float4(vertex_in.position, 1);
    VertexOut vertex_out;
    vertex_out.position = uniforms.view_proj_matrix * model_world_pos;
    vertex_out.frag_world_pos = model_world_pos.xyz;
    vertex_out.tex_coord = vertex_in.tex_coord;
    vertex_out.frag_world_normal = (uniforms.model_matrix * float4(vertex_in.normal, 1.0)).xyz;

    vertex_out.tangent = normalize(uniforms.normal_matrix * float3(vertex_in.tangent));
    vertex_out.normal = normalize(uniforms.normal_matrix * float3(vertex_in.normal));
//    vertex_out.tangent = normalize(vertex_out.tangent - dot(vertex_out.tangent, vertex_out.normal) * vertex_out.normal);
    vertex_out.bitangent = cross(vertex_out.normal, vertex_out.tangent);
    return vertex_out;
}

fragment float4
basic_fragment(VertexOut frag_in [[ stage_in ]],
               array<texture2d<float>, 5> texture2D [[ texture(0) ]],
               sampler sampler2D [[ sampler(0) ]],
               constant FragmentUniforms &uniforms [[ buffer(0) ]],
               constant Light &light [[ buffer(1) ]]) {
    constexpr sampler normalSampler(filter::nearest);
    float4 albedo_map = texture2D[0].sample(sampler2D, frag_in.tex_coord);
    float4 specular_map = texture2D[1].sample(sampler2D, frag_in.tex_coord);
    float3 normal_map = texture2D[2].sample(sampler2D, frag_in.tex_coord).rgb * 2.0f - 1.0f;

    float3x3 tbn_matrix(frag_in.tangent, frag_in.bitangent, frag_in.normal);

    float3 TangentLightPos = tbn_matrix * float3(light.position);
    float3 TangentViewPos  = tbn_matrix * float3(uniforms.camera_pos);
    float3 TangentFragPos  = tbn_matrix * frag_in.frag_world_pos;

    float3 normal = normalize(normal_map);
    float3 frag_light_dir = normalize(TangentLightPos - TangentFragPos);

    float ambient_intensity = 0.5f;
    float diffuse_intensity = 0.99f;
    float specular_intensity = 1.0f;

//    float3 normal = normalize(frag_in.frag_world_normal);
    // ambient
    float3 ambient = ambient_intensity * light.color * uniforms.mat_ambient;
//    if (light.type.x == LIGHT_TYPE_AMBIENT) {
//        return float4(ambient, 1.0f) * albedo_map;
//    }

//    if (light.type.x == LIGHT_TYPE_DIRECTIONAL) {
//        frag_light_dir = light_direction_neg;
//    }
    // diffuse
    float diffuse_factor = max(dot(frag_light_dir, normal), 0.0f);
//    float3 diffuse = diffuse_factor * diffuse_intensity * light.color * uniforms.mat_diffuse;
    float3 diffuse = diffuse_factor;

    // specular
//    float3 view_dir = normalize(TangentViewPos - TangentFragPos);
//    float3 reflect_dir = reflect(-frag_light_dir, normal);
//    float3 halfwayDir = normalize(frag_light_dir + view_dir);
//    float specular_factor = pow(max(dot(normal, halfwayDir), 0.0), uniforms.mat_shininess);
////    float specular_factor = pow(max(dot(view_dir, reflect_dir), 0.0f), uniforms.mat_shininess);
//    float3 specular = specular_factor * specular_intensity * light.color;

//    if (light.type.x == LIGHT_TYPE_OMNI) {
//        float light_dist = length(light.position - frag_in.frag_world_pos);
//        float light_const = 1.0f;
//        float light_liner = 0.09f;
//        float light_quad = 0.032f;
//        float attenuation = 1.0 / (light_const + light_liner * light_dist + light_quad * light_dist * light_dist);
//
//        ambient *= attenuation;
//        diffuse *= attenuation;
//        specular *= attenuation;
//    } else if (light.type.x == LIGHT_TYPE_SPOT) {
//        float3 light_direction_neg = normalize(-light.direction);
//        float theta = dot(frag_light_dir, light_direction_neg);
//        float epsilon = light.spot_inner_radian - light.spot_outer_radian;
//        float spot_intensity = clamp((theta - light.spot_outer_radian) / epsilon, 0.0, 1.0);
//
//        ambient = 0;
//        diffuse *= spot_intensity;
//        specular *= spot_intensity;
//    }

    float4 color = float4();
    color += float4(ambient, 1.0f);
    color += float4(diffuse, 1.0f) * albedo_map;
//    color += float4(specular, 1.0f) * specular_map;
    float4 final_color = color * 4.0;
    return final_color;
}

//float4
//map_textures() {
//    float4
//    return color;
//}
