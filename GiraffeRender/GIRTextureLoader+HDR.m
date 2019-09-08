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

@implementation GIRHDRLoader

+ (float*)loadHDR:(NSString * _Nonnull)hdrPath width:(NSInteger * _Nonnull)width height:(NSInteger * _Nonnull)height numComponents:(NSInteger * _Nonnull)numOfConmonents
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Art.scnassets/HDR/newport_loft" ofType:@"hdr"];
    float *data = stbi_loadf([path UTF8String], width, height, numOfConmonents, 4); // TODO: need to free resource
    return data;
}

@end
