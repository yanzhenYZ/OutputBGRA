//
//  YZBGRAPixelBuffer.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import "YZBGRAPixelBuffer.h"
#import <MetalKit/MetalKit.h>
#import "YZVideoData.h"
#import "YZMetalDevice.h"
#import "YZMetalOrientation.h"

@interface YZBGRAPixelBuffer ()

@end

@implementation YZBGRAPixelBuffer;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pipelineState = [YZMetalDevice.defaultDevice newRenderPipeline:@"YZInputVertex" fragment:@"YZFragment"];
    }
    return self;
}

- (CGRect)getCropWith:(CGSize)size videoData:(YZVideoData *)data {
    CGFloat x = data.cropLeft / size.width;
    CGFloat y = data.cropTop / size.height;
    CGFloat w =  1 - x - data.cropRight / size.width;
    CGFloat h =  1 - y - data.cropBottom / size.height;
    return CGRectMake(x, y, w, h);
}

- (void)inputVideo:(YZVideoData *)videoData {
    int width = (int)CVPixelBufferGetWidth(videoData.pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(videoData.pixelBuffer);
    //start 1
    [self cropTextureSize:CGSizeMake(width, height) videoData:videoData];
    //end 1
    if (![self continueMetal]) {  return; }
    CVMetalTextureRef tmpTexture = NULL;
    CVReturn status =  CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, videoData.pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tmpTexture);
    if (status != kCVReturnSuccess) {
        return;
    }
    
    id<MTLTexture> texture = CVMetalTextureGetTexture(tmpTexture);
    CFRelease(tmpTexture);
    
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:self.texture];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZBGRAPixelBuffer render endcoder Fail");
        return;
    }

    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    simd_float8 vertices = [YZMetalOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    //start 2
    CGRect crop = [self getCropWith:CGSizeMake(width, height) videoData:videoData];
    simd_float8 textureCoordinates = [YZMetalOrientation getCropRotationTextureCoordinates:videoData.rotation crop:crop];
    //end 2
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:texture atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    [self outoutVideoData:videoData];
}

- (void)inputVideo_keep:(YZVideoData *)videoData {
    int width = (int)CVPixelBufferGetWidth(videoData.pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(videoData.pixelBuffer);
    if (videoData.rotation == 90 || videoData.rotation == 270) {
        [self newDealTextureSize:CGSizeMake(height, width)];
    } else {
        [self newDealTextureSize:CGSizeMake(width, height)];
    }
    
    if (![self continueMetal]) {  return; }
#if 1
    CVMetalTextureRef tmpTexture = NULL;
    CVReturn status =  CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, videoData.pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tmpTexture);
    if (status != kCVReturnSuccess) {
        return;
    }
    
    id<MTLTexture> texture = CVMetalTextureGetTexture(tmpTexture);
    CFRelease(tmpTexture);
#else//多消耗2% CPU
    MTLTextureDescriptor *tDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:width height:height mipmapped:NO];
    tDesc.usage = MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    CVPixelBufferLockBaseAddress(videoData.pixelBuffer, 0);
    const void *bytes = CVPixelBufferGetBaseAddress(videoData.pixelBuffer);
    id<MTLTexture> texture = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:tDesc];
    [texture replaceRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0 withBytes:bytes bytesPerRow:CVPixelBufferGetBytesPerRow(videoData.pixelBuffer)];
    CVPixelBufferUnlockBaseAddress(videoData.pixelBuffer, 0);
#endif
    
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:self.texture];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZBGRAPixelBuffer render endcoder Fail");
        return;
    }

    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    simd_float8 vertices = [YZMetalOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = [YZMetalOrientation getRotationTextureCoordinates:videoData.rotation];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:texture atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    [self outoutVideoData:videoData];
}
@end
