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
@property (nonatomic, strong) YZPixelBuffer *pixelBuffer;
@property (nonatomic, strong) YZBGRAPixelBuffer *bgraBuffer;
@property (nonatomic, strong) YZYUVVideoRangePixelBuffer *videoRangeBuffer;
@property (nonatomic, strong) YZYUVFullRangePixelBuffer *fullRangeBuffer;
@property (nonatomic, strong) YZYUVDataPixelBuffer *dataBuffer;
@end

@implementation YZCropFilter

- (void)setOutputPixelBuffer:(YZPixelBuffer *)pixelBuffer {
    _pixelBuffer = pixelBuffer;
}

- (void)inputVideo:(YZVideoData *)videoData {
    if (videoData.pixelBuffer) {
        [self dealPixelBuffer:videoData];
    } else {
        [self.dataBuffer inputVideo:videoData];
    }
}
#pragma mark - helper
- (void)dealPixelBuffer:(YZVideoData *)videoData {
    OSType type = CVPixelBufferGetPixelFormatType(videoData.pixelBuffer);
    if (type == kCVPixelFormatType_32BGRA) {
        if ([self needCropRotation:videoData]) {
            [self.bgraBuffer inputVideo:videoData];
        } else {
            [self.pixelBuffer outoutPixelBuffer:videoData.pixelBuffer videoData:videoData];
        }
    } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        [self.videoRangeBuffer inputVideo:videoData];
    } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        [self.fullRangeBuffer inputVideo:videoData];
    }
}

- (BOOL)needCropRotation:(YZVideoData *)data {
    if (data.rotation == 0 && data.cropTop == 0 && data.cropBottom == 0 && data.cropRight == 0 && data.cropLeft == 0) {
        return NO;
    }
    return YES;
}

#pragma mark - lazy var
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
@end
