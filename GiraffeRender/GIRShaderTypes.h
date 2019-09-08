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
    LightTypeAmbient = 0,
    LightTypeDirectional = 1,
    LightTypeOmni = 2,
    LightTypeSpot = 3,
} LightType;

#endif /* GIRShaderTypes_h */
