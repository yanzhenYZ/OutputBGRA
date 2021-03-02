//
//  YZSuperPixelBuffer.h
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/2.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <MetalKit/MetalKit.h>

@class YZVideoData;
@class YZPixelBuffer;
@interface YZSuperPixelBuffer : NSObject
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLTexture> texture;

- (void)inputVideo:(YZVideoData *)videoData;
- (void)setOutputPixelBuffer:(YZPixelBuffer *)pixelBuffer;
- (void)newDealTextureSize:(CGSize)size;
- (void)outoutVideoData:(YZVideoData *)data;
- (BOOL)continueMetal;
@end


