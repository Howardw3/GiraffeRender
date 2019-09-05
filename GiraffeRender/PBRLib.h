//
//  PBRLib.h
//  GiraffeRender
//
//  Created by Howard Wang on 9/4/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

#ifndef PBRLib_h
#define PBRLib_h

float distributionGGX(float3 N, float3 H, float roughness);
float geometry_schlickGGX(float NdotV, float roughness);
float geometry_smith(float3 N, float3 V, float3 L, float roughness);
float3 fresnel_schlick(float cosTheta, float3 F0);
float3 fresnel_schlick_roughness(float cosTheta, float3 F0, float roughness);
float2 integrate_BRDF(float NdotV, float roughness);

#endif /* PBRLib_h */
