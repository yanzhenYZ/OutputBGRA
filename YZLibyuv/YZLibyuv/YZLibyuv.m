//
//  YZLibyuv.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import "YZLibyuv.h"
#import "LibyuvBGRAPixelBuffer.h"
#import "YZLibyuvPixelBuffer.h"
#import "LibyuvFullRangePixelBuffer.h"
#import "LibyuvVideoRangePixelBuffer.h"
#import "LibyuvYUVDataPixelBuffer.h"
#import "YZLibyuvTool.h"

/** todo
 2. test bgra转I420
 */
@interface YZLibyuv ()<YZLibyuvPixelBufferDelegate>
@property (nonatomic, strong) YZLibyuvPixelBuffer *pixelBuffer;
@property (nonatomic, strong) LibyuvBGRAPixelBuffer *bgraPixelBuffer;
@property (nonatomic, strong) LibyuvFullRangePixelBuffer *fullPixelBuffer;
@property (nonatomic, strong) LibyuvVideoRangePixelBuffer *videoPixelBuffer;
@property (nonatomic, strong) LibyuvYUVDataPixelBuffer *yuvPixelBuffer;
@end

@implementation YZLibyuv
- (instancetype)init
{
    self = [super init];
    if (self) {
        _pixelBuffer = [[YZLibyuvPixelBuffer alloc] init];
        _pixelBuffer.delegate = self;
    }
    return self;
}

- (void)inputVideoData:(YZLibVideoData *)videoData {
    if (videoData.pixelBuffer) {
        OSType type = CVPixelBufferGetPixelFormatType(videoData.pixelBuffer);
        if (type == kCVPixelFormatType_32BGRA) {
            [self.bgraPixelBuffer inputVideoData:videoData];
        } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
            [self.videoPixelBuffer inputVideoData:videoData];
        } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {//todo
            [self.fullPixelBuffer inputVideoData:videoData];
        }
    } else {
        [self.yuvPixelBuffer inputVideoData:videoData];
    }
}

#pragma mark - YZLibyuvPixelBufferDelegate
- (void)buffer:(YZLibyuvPixelBuffer *)buffer pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if ([_delegate respondsToSelector:@selector(libyuv:pixelBuffer:)]) {
        [_delegate libyuv:self pixelBuffer:pixelBuffer];
    }
}

#pragma mark - test
+ (void)BGRAToI420:(uint8_t *)bgra bgraStride:(int)bgraStride dstY:(uint8_t *)y strideY:(int)strideY dstU:(uint8_t *)u strideU:(int)strideU dstV:(uint8_t *)v strideV:(int)strideV width:(int)width height:(int)height {
    [YZLibyuvTool BGRAToI420:bgra bgraStride:bgraStride dstY:y strideY:strideY dstU:u strideU:strideU dstV:v strideV:strideV width:width height:height];
}
#pragma mark - lazy var
- (LibyuvBGRAPixelBuffer *)bgraPixelBuffer {
    if (!_bgraPixelBuffer) {
        _bgraPixelBuffer = [[LibyuvBGRAPixelBuffer alloc] init];
        [_bgraPixelBuffer setOutputBuffer:_pixelBuffer];
    }
    return _bgraPixelBuffer;
}

- (LibyuvFullRangePixelBuffer *)fullPixelBuffer {
    if (!_fullPixelBuffer) {
        _fullPixelBuffer = [[LibyuvFullRangePixelBuffer alloc] init];
        [_fullPixelBuffer setOutputBuffer:_pixelBuffer];
    }
    return _fullPixelBuffer;
}

- (LibyuvVideoRangePixelBuffer *)videoPixelBuffer {
    if (!_videoPixelBuffer) {
        _videoPixelBuffer = [[LibyuvVideoRangePixelBuffer alloc] init];
        [_videoPixelBuffer setOutputBuffer:_pixelBuffer];
    }
    return _videoPixelBuffer;
}

- (LibyuvYUVDataPixelBuffer *)yuvPixelBuffer {
    if (!_yuvPixelBuffer) {
        _yuvPixelBuffer = [[LibyuvYUVDataPixelBuffer alloc] init];
        [_yuvPixelBuffer setOutputBuffer:_pixelBuffer];
    }
    return _yuvPixelBuffer;
}
@end
