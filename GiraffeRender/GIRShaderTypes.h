//
//  GIRShaderTypes.h
//  GiraffeRender
//
//  Created by Howard Wang on 9/6/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

#ifndef GIRShaderTypes_h
#define GIRShaderTypes_h

#include <simd/simd.h>

typedef enum LightType
{
    LightTypeAmbient        = 0,
    LightTypeDirectional    = 1,
    LightTypeOmni           = 2,
    LightTypeSpot           = 3
} LightType;

typedef enum PBRTextureIndex
{
    PBRTexIndexShadow       = 0,
    PBRTexIndexIrradiance   = 1,
    PBRTexIndexEnvironment  = 2,
    PBRTexIndexTextures     = 3
} PBRTextureIndex;

typedef enum PBRFragBuferIndex
{
    PBRFragBufIndexFragment     = 0,
    PBRFragBufIndexLight        = 1
} PBRFragBuferIndex;

typedef enum PBRSamplerStateIndex
{
    PRBSamplerStateIndexNearest = 0,
    PRBSamplerStateIndexLinear  = 1,
    PRBSamplerStateIndexEnv     = 2,
} PBRSamplerStateIndex;

typedef enum QualityLevel
{
    QualityLevelLow     = 0,
    QualityLevelMedium  = 1,
    QualityLevelHigh    = 2,
};

#endif /* GIRShaderTypes_h */
