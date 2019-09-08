//
//  GIRTextureLoader+HDR.h
//  GiraffeRender
//
//  Created by Howard Wang on 9/2/19.
//  Copyright © 2019 Jiongzhi Wang. All rights reserved.
//

#ifndef GIRTextureLoader_HDR_h
#define GIRTextureLoader_HDR_h

@interface GIRHDRLoader : NSObject

+ (float*)loadHDR:(NSString *)hdrPath width:(int32_t *)width height:(int32_t *)height numComponents:(int32_t *)numOfConmonents;

@end

#endif /* GIRTextureLoader_HDR_h */
