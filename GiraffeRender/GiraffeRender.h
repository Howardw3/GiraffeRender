//
//  GiraffeRender.h
//  GiraffeRender
//
//  Created by Howard Wang on 8/10/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for GiraffeRender.
FOUNDATION_EXPORT double GiraffeRenderVersionNumber;

//! Project version string for GiraffeRender.
FOUNDATION_EXPORT const unsigned char GiraffeRenderVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GiraffeRender/PublicHeader.h>


#include <stdint.h>
static inline void storeAsF16(float value, uint16_t *pointer) { *(__fp16 *)pointer = value; }
