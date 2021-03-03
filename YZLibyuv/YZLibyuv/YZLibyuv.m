//
//  YZLibyuv.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import "YZLibyuv.h"
#import "LibyuvBGRAPixelBuffer.h"
#import "YZLibyuvPixelBuffer.h"

@interface YZLibyuv ()<YZLibyuvPixelBufferDelegate>
@property (nonatomic, strong) YZLibyuvPixelBuffer *pixelBuffer;
@property (nonatomic, strong) LibyuvBGRAPixelBuffer *bgraPixelBuffer;
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
            
        } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
            
        }
    } else {
        
    }
}

#pragma mark - YZLibyuvPixelBufferDelegate
- (void)buffer:(YZLibyuvPixelBuffer *)buffer pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if ([_delegate respondsToSelector:@selector(libyuv:pixelBuffer:)]) {
        [_delegate libyuv:self pixelBuffer:pixelBuffer];
    }
}

#pragma mark - lazy var
- (LibyuvBGRAPixelBuffer *)bgraPixelBuffer {
    if (!_bgraPixelBuffer) {
        _bgraPixelBuffer = [[LibyuvBGRAPixelBuffer alloc] init];
        [_bgraPixelBuffer setOutputBuffer:_pixelBuffer];
    }
    return _bgraPixelBuffer;
}

@end
