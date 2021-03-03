//
//  YZSuperPixelBuffer.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/2.
//

#import "YZSuperPixelBuffer.h"
#import "YZPixelBuffer.h"
#import "YZMetalDevice.h"
#import "YZVideoData.h"

@interface YZSuperPixelBuffer ()
@property (nonatomic) CGSize size;
@property (nonatomic, strong) YZPixelBuffer *buffer;
@end

@implementation YZSuperPixelBuffer {
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

- (void)setOutputPixelBuffer:(YZPixelBuffer *)pixelBuffer {
    _buffer = pixelBuffer;
}

- (void)outoutVideoData:(YZVideoData *)data {
    [self.buffer outoutPixelBuffer:_pixelBuffer videoData:data];
}

- (BOOL)continueMetal {
    if (!_pixelBuffer || !_texture) {
        return NO;
    }
    return YES;
}
#pragma mark - helper
- (void)cropTextureSize:(CGSize)size videoData:(YZVideoData *)data {
    if (data.rotation == 90 || data.rotation == 270) {
        [self newDealTextureSize:CGSizeMake(size.height, size.width)];
    } else {
        [self newDealTextureSize:size];
    }
}

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
        NSLog(@"YZBGRAPixelBuffer to create cvpixelbuffer %d", result);
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
