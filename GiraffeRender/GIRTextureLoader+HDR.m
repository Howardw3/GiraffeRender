//
//  GIRTextureLoader+HDR.m
//  GiraffeRender
//
//  Created by Howard Wang on 9/2/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GIRTextureLoader+HDR.h"
#include <stdio.h>

#define STB_IMAGE_IMPLEMENTATION
#include "utility/stb_image.h"
//#define __cplusplus

@implementation GIRHDRLoader

+ (float*)loadHDR:(NSString *)hdrPath width:(NSInteger *)width height:(NSInteger *)height numComponents:(NSInteger *)numOfConmonents
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Art.scnassets/HDR/newport_loft" ofType:@"hdr"];
    float *data = stbi_loadf([path UTF8String], width, height, numOfConmonents, 4); // TODO: need to free resource
    return data;
}

@end
