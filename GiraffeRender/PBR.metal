//
//  PBR.metal
//  GiraffeRender
//
//  Created by Howard Wang on 8/28/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

#include <metal_stdlib>
#include "PBRLib.h"
#include "GIRShaderTypes.h"
using namespace metal;

constant float PI = 3.14159265359;
constant int MAT_MATERIAL_COUNT = 5;

// PBR material type
typedef enum MaterialType
{
    MatAlbedo       = 0,
    MatMetalness    = 1,
    MatRoughness    = 2,
    MatNormal       = 3,
    MatAO           = 4,
    MatEmission     = 5,
} MaterialType;

struct VertexUniforms {
    float4x4 view_proj_matrix;
    float4x4 model_matrix;
    float3x3 normal_matrix;
    float4x4 light_space_matrix;
};

struct MaterialColor {
    float3 colors[MAT_MATERIAL_COUNT];
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
    float4 frag_shadow_pos;
    float3 tangent;
    float3 bitangent;
    float3 normal;
};

struct FragmentUniforms {
    packed_float3 camera_pos;
    float mat_shininess;
    float colorTypes[MAT_MATERIAL_COUNT];
    packed_float3 colors[MAT_MATERIAL_COUNT];

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

static MaterialColor
get_material_colors(FragmentUniforms uniforms,
                    array<texture2d<float>, MAT_MATERIAL_COUNT> textures2D,
                    float2 tex_coord,
                    sampler linearSampler2D,
                    sampler nearestSampler2D)
{
    int textureCounter = 0;
    MaterialColor color;
    tex_coord.y = 1.0f - tex_coord.y;

    for (int i = 0; i < MAT_MATERIAL_COUNT; i++) {
        if (uniforms.colorTypes[i] >= 0.0) {
            color.colors[i] = uniforms.colors[i];
        } else if (uniforms.colorTypes[i] < 0.0) {
            if (i == MatNormal) {
                color.colors[i] = textures2D[textureCounter].sample(nearestSampler2D, tex_coord).rgb * 2.0f - 1.0f;
            } else {
                color.colors[i] = textures2D[textureCounter].sample(linearSampler2D, tex_coord).rgb;
            }

            textureCounter += 1;
        }
    }

    return color;
}

vertex VertexOut
pbr_vertex(constant VertexIn* vertex_array [[ buffer(0) ]],
             constant VertexUniforms& uniforms [[ buffer(1) ]],
             uint vid [[ vertex_id ]]) {

    VertexIn vertex_in = vertex_array[vid];

    float4 model_world_pos = uniforms.model_matrix * float4(vertex_in.position, 1.0f);
    VertexOut vertex_out;
    vertex_out.position = uniforms.view_proj_matrix * model_world_pos;
    vertex_out.frag_world_pos = model_world_pos.xyz;
    vertex_out.tex_coord = vertex_in.tex_coord;
    vertex_out.frag_world_normal = (uniforms.model_matrix * float4(vertex_in.normal, 1.0f)).xyz;
    vertex_out.frag_shadow_pos = uniforms.light_space_matrix * model_world_pos;

    vertex_out.tangent = normalize(uniforms.normal_matrix * vertex_in.tangent.xyz);
    vertex_out.normal = normalize(uniforms.normal_matrix * vertex_in.normal.xyz);
    vertex_out.tangent = normalize(vertex_out.tangent - dot(vertex_out.tangent, vertex_out.normal) * vertex_out.normal);
    vertex_out.bitangent = cross(vertex_out.normal, vertex_out.tangent);
    return vertex_out;
}

fragment float4
pbr_fragment(VertexOut frag_in [[ stage_in ]],
             depth2d<float> shadow_texture2D [[ texture(PBRTexIndexShadow) ]],
             texturecube<float> irradianceMap [[ texture(PBRTexIndexIrradiance) ]],
             texturecube<float> environmentMap [[ texture(PBRTexIndexEnvironment) ]],
             array<texture2d<float>, MAT_MATERIAL_COUNT> textures2D [[ texture(PBRTexIndexTextures) ]],
             sampler nearestSampler2D [[ sampler(PRBSamplerStateIndexNearest) ]],
             sampler linearSampler2D [[ sampler(PRBSamplerStateIndexLinear) ]],
             sampler envSampler2D [[ sampler(PRBSamplerStateIndexEnv) ]],
             constant FragmentUniforms &uniforms [[ buffer(PBRFragBufIndexFragment) ]],
             constant Light &light [[ buffer(PBRFragBufIndexLight) ]])
{
    MaterialColor mat_colors = get_material_colors(uniforms, textures2D, frag_in.tex_coord, linearSampler2D, nearestSampler2D);

    float3 mat_normal = mat_colors.colors[MatNormal];
    float3 mat_albedo = mat_colors.colors[MatAlbedo];
    float mat_metalness = mat_colors.colors[MatMetalness].r;
    float mat_ao = mat_colors.colors[MatAO].r;
    float mat_roughness = mat_colors.colors[MatRoughness].r;

    float3x3 tbn_matrix(frag_in.tangent, frag_in.bitangent, frag_in.normal);

    float3 tangent_light_pos = tbn_matrix * float3(light.position);
    float3 tangent_view_pos  = tbn_matrix * float3(uniforms.camera_pos);
    float3 tangent_frag_pos  = tbn_matrix * frag_in.frag_world_pos;

    float3 N = normalize(tbn_matrix * mat_normal);
    float3 V = normalize(tangent_view_pos - tangent_frag_pos);
    float3 R = reflect(-V, N);

    float3 frag_light_dir = normalize(tangent_light_pos - tangent_frag_pos);

    // calculate reflectance at normal incidence; if dia-electric (like plastic) use F0
    // of 0.04 and if it's a metal, use the albedo color as F0 (metallic workflow)
    float3 F0 = float3(0.04);
    F0 = mix(F0, mat_albedo, mat_metalness);

    // reflectance equation
    float3 Lo = float3(0.0);
//    for(int i = 0; i < 4; ++i)
//    {
        // calculate per-light radiance
        float3 L = frag_light_dir;
        float3 H = normalize(V + L);
        float distance = length(light.position - frag_in.frag_world_pos);
        float attenuation = 1.0 / (distance * distance);
        float3 radiance = light.color * attenuation  * light.intensity;

        // Cook-Torrance BRDF
        float NDF = distributionGGX(N, H, mat_roughness);
        float G   = geometry_smith(N, V, L, mat_roughness);
        float3 F    = fresnel_schlick(max(dot(H, V), 0.0), F0);

        float3 nominator    = NDF * G * F;
        float denominator = 4 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.001; // 0.001 to prevent divide by zero.
        float3 specular = nominator / denominator;

        // kS is equal to Fresnel
        float3 kS = F;
        // for energy conservation, the diffuse and specular light can't
        // be above 1.0 (unless the surface emits light); to preserve this
        // relationship the diffuse component (kD) should equal 1.0 - kS.
        float3 kD = float3(1.0) - kS;
        // multiply kD by the inverse metalness such that only non-metals
        // have diffuse lighting, or a linear blend if partly metal (pure metals
        // have no diffuse light).
        kD *= 1.0 - mat_metalness;

        // scale light by NdotL
        float NdotL = max(dot(N, L), 0.0);

        // add to outgoing radiance Lo
        Lo += (kD * mat_albedo / PI + specular) * radiance * NdotL;  // note that we already multiplied the BRDF by the Fresnel (kS) so we won't multiply by kS again
//    }

    float3 kS1 = fresnel_schlick_roughness(max(dot(N, V), 0.0), F0, mat_roughness);
    float3 kD1 = 1.0 - kS1;
    kD1 *= 1.0 - mat_metalness;
    float3 irradiance = irradianceMap.sample(envSampler2D, N).rgb;
    float3 diffuse_final = irradiance * mat_albedo;

    float mipLevel = mat_roughness * irradianceMap.get_num_mip_levels();
    float3 irradiance_mip = environmentMap.sample(envSampler2D, R, level(mipLevel)).rgb;
//    float2 brdf = integrate_BRDF(max(dot(N, V), 0.0), mat_roughness);
//    float3 specular_final = irradiance_mip * (kS1 * brdf.x + brdf.y);
    float3 specular_final = (nominator * irradiance_mip) * ((1.0 - mat_metalness) * mat_albedo) + irradiance_mip * mat_metalness * mat_albedo;

    float3 ambient = (kD1 * diffuse_final + specular_final) * mat_ao;
//    float3 ambient = float3(0.03) * mat_albedo * mat_ao;
    float3 color = ambient + Lo;

    // HDR tonemapping
//    color = color / (color + float3(1.0));
    // gamma correct
//    color = pow(color, float3(1.0/2.2));

    return float4(color, 1.0);
}
