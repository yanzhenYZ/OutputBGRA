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
        _pipelineState = [YZMetalDevice.defaultDevice newRenderPipeline:@"YZYUVDataToRGBVertex" fragment:@"YZYUVDataConversionFullRangeFragment"];//fullRange
        _colorConversion = kYZColorConversion709;
//        _colorConversion = kYZColorConversion601FullRange;
//        _colorConversion = kYZColorConversion601;
    }
    return self;
}

- (void)setOutputPixelBuffer:(YZPixelBuffer *)pixelBuffer {
    _buffer = pixelBuffer;
}
//CPU 3%
- (void)inputVideoData:(YZVideoData *)videoData {
    int width = videoData.width;
    int height = videoData.height;
    if (videoData.rotation == 90 || videoData.rotation == 270) {
        [self newDealTextureSize:CGSizeMake(height, width)];
    } else {
        [self newDealTextureSize:CGSizeMake(width, height)];
    }
    if (!_pixelBuffer || !_texture) { return; }
    
    MTLTextureDescriptor *yDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width height:height mipmapped:NO];
    yDesc.usage = MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    id<MTLTexture> textureY = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:yDesc];
    [textureY replaceRegion:MTLRegionMake2D(0, 0, textureY.width, textureY.height) mipmapLevel:0 withBytes:videoData.yBuffer bytesPerRow:videoData.yStride];
    
    MTLTextureDescriptor *uDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width / 2 height:height / 2 mipmapped:NO];
    uDesc.usage = MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    id<MTLTexture> textureU = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:uDesc];
    [textureU replaceRegion:MTLRegionMake2D(0, 0, textureU.width, textureU.height) mipmapLevel:0 withBytes:videoData.uBuffer bytesPerRow:videoData.uStride];
    
    MTLTextureDescriptor *vDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width / 2 height:height / 2 mipmapped:NO];
    vDesc.usage = MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    id<MTLTexture> textureV = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:vDesc];
    [textureV replaceRegion:MTLRegionMake2D(0, 0, textureV.width, textureV.height) mipmapLevel:0 withBytes:videoData.vBuffer bytesPerRow:videoData.vStride];
    
    [self convertYUVToRGB:textureY textureU:textureU textureV:textureV rotation:videoData.rotation];
}

- (void)convertYUVToRGB:(id<MTLTexture>)textureY textureU:(id<MTLTexture>)textureU textureV:(id<MTLTexture>)textureV rotation:(int)rotation {
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
    [encoder setFragmentTexture:textureU atIndex:1];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:3];
    [encoder setFragmentTexture:textureV atIndex:2];

    id<MTLBuffer> uniformBuffer = [YZMetalDevice.defaultDevice.device newBufferWithBytes:_colorConversion length:sizeof(float) * 12 options:MTLResourceCPUCacheModeDefaultCache];
    [encoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    
    [self.buffer outoutPixelBuffer:_pixelBuffer];
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
        NSLog(@"YZYUVDataPixelBuffer to create cvpixelbuffer %d", result);
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

