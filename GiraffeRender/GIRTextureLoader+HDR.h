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

+ (float*)loadHDR:(NSString *)hdrPath width:(NSInteger *)width height:(NSInteger *)height numComponents:(NSInteger *)numOfConmonents;

@end

#endif /* GIRTextureLoader_HDR_h */
