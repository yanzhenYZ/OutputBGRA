//
//  YZPixelBuffer.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import "YZPixelBuffer.h"
#import "YZMetalDevice.h"
#import "YZMetalOrientation.h"

@interface YZPixelBuffer ()
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic) CGSize size;
@end

@implementation YZPixelBuffer {
    CVPixelBufferRef _pixelBuffer;
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
        _pipelineState = [YZMetalDevice.defaultDevice newRenderPipeline:@"YZInputVertex" fragment:@"YZFragment"];
    }
    return self;
}

- (void)outoutPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if ([_delegate respondsToSelector:@selector(buffer:pixelBuffer:)]) {
        [_delegate buffer:self pixelBuffer:pixelBuffer];
    }
}

- (void)newTextureAvailable:(id<MTLTexture>)texture {
    [self newDealTextureSize:texture];
    if (!_pixelBuffer || !_texture) { return; }
    
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:_texture];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZPixelBuffer render endcoder Fail");
        return;
    }

    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    simd_float8 vertices = [YZMetalOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = [YZMetalOrientation defaultTextureCoordinates];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:texture atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    
    [self outoutPixelBuffer:_pixelBuffer];
}

#pragma mark - helper
- (void)newDealTextureSize:(id<MTLTexture>)texture {
    CGFloat width = texture.width;
    CGFloat height = texture.height;
    if (!CGSizeEqualToSize(_size, CGSizeMake(width, height))) {
        if (_pixelBuffer) {
            CVPixelBufferRelease(_pixelBuffer);
            _pixelBuffer = nil;
        }
        _size = CGSizeMake(width, height);
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
        NSLog(@"YZNewPixelBuffer to create cvpixelbuffer %d", result);
        return;
    }
    
    CVMetalTextureRef textureRef = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, _pixelBuffer, nil, MTLPixelFormatBGRA8Unorm, width, height, 0, &textureRef);
    if (kCVReturnSuccess != status) {
        return;
    }
    _texture = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
}
@end
