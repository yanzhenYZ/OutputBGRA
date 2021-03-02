//
//  YZYUVVideoRangePixelBuffer.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/2.
//

#import "YZYUVVideoRangePixelBuffer.h"
#import "YZMetalOrientation.h"
#import "YZMetalDevice.h"
#import "YZVideoData.h"


@implementation YZYUVVideoRangePixelBuffer {
    CVPixelBufferRef _pixelBuffer;
    const float *_colorConversion; //4x3
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pipelineState = [YZMetalDevice.defaultDevice newRenderPipeline:@"YZYUVToRGBVertex" fragment:@"YZYUVConversionVideoRangeFragment"];
    }
    return self;
}

- (void)inputVideo:(YZVideoData *)videoData {
    CVPixelBufferRef pixelBuffer = videoData.pixelBuffer;
    size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    if (videoData.rotation == 90 || videoData.rotation == 270) {
        [self newDealTextureSize:CGSizeMake(height, width)];
    } else {
        [self newDealTextureSize:CGSizeMake(width, height)];
    }
    
    if (![self continueMetal]) {  return; }
    
    CVMetalTextureRef textureRef = NULL;
    id<MTLTexture> textureY = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatR8Unorm, width, height, 0, &textureRef);
    if(status != kCVReturnSuccess) {
        return;
    }
    textureY = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    id<MTLTexture> textureUV = NULL;
    width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatRG8Unorm, width, height, 1, &textureRef);
    if(status != kCVReturnSuccess) {
        return;
    }
    textureUV = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    height = CVPixelBufferGetHeight(pixelBuffer);
    width = CVPixelBufferGetWidth(pixelBuffer);
    CFTypeRef attachment = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
    if (attachment != NULL) {
        if(CFStringCompare(attachment, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
            _colorConversion = kYZColorConversion601;
        } else {
            _colorConversion = kYZColorConversion709;
        }
    } else {
        _colorConversion = kYZColorConversion601;
    }
    
    [self convertYUVToRGB:textureY textureUV:textureUV rotation:videoData.rotation];
    [self outoutVideoData:videoData];
}

- (void)convertYUVToRGB:(id<MTLTexture>)textureY textureUV:(id<MTLTexture>)textureUV rotation:(int)rotation {
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:self.texture];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZYUVVideoRangePixelBuffer render endcoder Fail");
        return;
    }
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    
    simd_float8 vertices = [YZMetalOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = [YZMetalOrientation getRotationTextureCoordinates:rotation];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:textureY atIndex:0];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:2];
    [encoder setFragmentTexture:textureUV atIndex:1];

    id<MTLBuffer> uniformBuffer = [YZMetalDevice.defaultDevice.device newBufferWithBytes:_colorConversion length:sizeof(float) * 12 options:MTLResourceCPUCacheModeDefaultCache];
    [encoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
}

@end

