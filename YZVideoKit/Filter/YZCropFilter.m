//
//  YZCropFilter.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import "YZCropFilter.h"
#import <MetalKit/MetalKit.h>
#import "YZPixelBuffer.h"
#import "YZVideoData.h"
#import "YZMetalDevice.h"
#import "YZMetalOrientation.h"
#import "YZBGRAPixelBuffer.h"
#import "YZYUVVideoRangePixelBuffer.h"
#import "YZYUVFullRangePixelBuffer.h"
#import "YZYUVDataPixelBuffer.h"

@interface YZCropFilter ()
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;

@property (nonatomic, strong) YZPixelBuffer *pixelBuffer;
@property (nonatomic, strong) YZBGRAPixelBuffer *bgraBuffer;
@property (nonatomic, strong) YZYUVVideoRangePixelBuffer *videoRangeBuffer;
@property (nonatomic, strong) YZYUVFullRangePixelBuffer *fullRangeBuffer;
@property (nonatomic, strong) YZYUVDataPixelBuffer *dataBuffer;
@end

@implementation YZCropFilter
- (void)dealloc
{
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
        _textureCache = nil;
    }
}

- (YZBGRAPixelBuffer *)bgraBuffer {
    if (!_bgraBuffer) {
        _bgraBuffer = [[YZBGRAPixelBuffer alloc] init];
        [_bgraBuffer setOutputPixelBuffer:_pixelBuffer];
    }
    return _bgraBuffer;
}

- (YZYUVVideoRangePixelBuffer *)videoRangeBuffer {
    if (!_videoRangeBuffer) {
        _videoRangeBuffer = [[YZYUVVideoRangePixelBuffer alloc] init];
        [_videoRangeBuffer setOutputPixelBuffer:_pixelBuffer];
    }
    return _videoRangeBuffer;
}

- (YZYUVFullRangePixelBuffer *)fullRangeBuffer {
    if (!_fullRangeBuffer) {
        _fullRangeBuffer = [[YZYUVFullRangePixelBuffer alloc] init];
        [_fullRangeBuffer setOutputPixelBuffer:_pixelBuffer];
    }
    return _fullRangeBuffer;
}

- (YZYUVDataPixelBuffer *)dataBuffer {
    if (!_dataBuffer) {
        _dataBuffer = [[YZYUVDataPixelBuffer alloc] init];
        [_dataBuffer setOutputPixelBuffer:_pixelBuffer];
    }
    return _dataBuffer;
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
    _pixelBuffer = pixelBuffer;
}

- (void)inputVideo:(YZVideoData *)videoData {
    if (videoData.pixelBuffer) {
        [self dealPixelBuffer:videoData];
    } else {
        [self.dataBuffer inputVideoData:videoData];
    }
}
#pragma mark - helper
- (void)dealPixelBuffer:(YZVideoData *)videoData {
    OSType type = CVPixelBufferGetPixelFormatType(videoData.pixelBuffer);
    if (type == kCVPixelFormatType_32BGRA) {
        if (videoData.rotation == 0) {
            [_pixelBuffer outoutPixelBuffer:videoData.pixelBuffer videoData:videoData];
        } else {
            [self.bgraBuffer inputVideo:videoData];
        }
    } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        [self.videoRangeBuffer inputVideoData:videoData];
    } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        [self.fullRangeBuffer inputVideo:videoData];
    }
}

@end
