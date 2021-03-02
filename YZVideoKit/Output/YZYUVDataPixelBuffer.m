//
//  YZYUVDataPixelBuffer.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/2.
//

#import "YZYUVDataPixelBuffer.h"
#import <MetalKit/MetalKit.h>
#import "YZMetalOrientation.h"
#import "YZPixelBuffer.h"
#import "YZMetalDevice.h"
#import "YZVideoData.h"

@interface YZYUVDataPixelBuffer ()
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic) CGSize size;

@property (nonatomic, strong) YZPixelBuffer *buffer;
@end

@implementation YZYUVDataPixelBuffer {
    CVPixelBufferRef _pixelBuffer;
    const float *_colorConversion; //4x3
}

- (void)dealloc
{
    if (_pixelBuffer) {
        CVPixelBufferRelease(_pixelBuffer);
        _pixelBuffer = nil;
    }
    
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
        _textureCache = nil;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CVMetalTextureCacheCreate(NULL, NULL, YZMetalDevice.defaultDevice.device, NULL, &_textureCache);
        _pipelineState = [YZMetalDevice.defaultDevice newRenderPipeline:@"YZYUVToRGBVertex" fragment:@"YZYUVConversionFullRangeFragment"];//fullRange
    }
    return self;
}

- (void)setOutputPixelBuffer:(YZPixelBuffer *)pixelBuffer {
    _buffer = pixelBuffer;
}

- (void)inputVideoData:(YZVideoData *)videoData {
    NSLog(@"todo:%d:%d:%@", videoData.width, videoData.height, _buffer);
}

- (void)convertYUVToRGB:(id<MTLTexture>)textureY textureUV:(id<MTLTexture>)textureUV rotation:(int)rotation {
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:_texture];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZYUVFullRangePixelBuffer render endcoder Fail");
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
    
    [self.buffer outoutPixelBuffer:_pixelBuffer];
}

#pragma mark - helper
- (void)newDealTextureSize:(CGSize)size {
    if (!CGSizeEqualToSize(_size, size)) {
        if (_pixelBuffer) {
            CVPixelBufferRelease(_pixelBuffer);
            _pixelBuffer = nil;
        }
        _size = size;
    }
    
    if (_pixelBuffer) { return; }
    NSDictionary *pixelAttributes = @{(NSString *)kCVPixelBufferIOSurfacePropertiesKey:@{}};
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                            _size.width,
                                            _size.height,
                                            kCVPixelFormatType_32BGRA,
                                            (__bridge CFDictionaryRef)(pixelAttributes),
                                            &_pixelBuffer);
    if (result != kCVReturnSuccess) {
        NSLog(@"YZYUVFullRangePixelBuffer to create cvpixelbuffer %d", result);
        return;
    }
    
    CVMetalTextureRef textureRef = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, _pixelBuffer, nil, MTLPixelFormatBGRA8Unorm, size.width, size.height, 0, &textureRef);
    if (kCVReturnSuccess != status) {
        return;
    }
    _texture = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
}
@end

