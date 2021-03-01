//
//  YZVideoOutput.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import "YZVideoOutput.h"
#import "YZPixelBuffer.h"
#import "YZCropFilter.h"

@interface YZVideoOutput ()<YZPixelBufferDelegate>
@property (nonatomic, strong) YZCropFilter *cropFilter;
@property (nonatomic, strong) YZPixelBuffer *pixelBuffer;
@end

@implementation YZVideoOutput

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cropFilter = [[YZCropFilter alloc] init];
        _pixelBuffer = [[YZPixelBuffer alloc] init];
        _pixelBuffer.delegate = self;
        [_cropFilter setOutputPixelBuffer:_pixelBuffer];
    }
    return self;
}

- (void)inputVideo:(YZVideoData *)videoData {
    [_cropFilter inputVideo:videoData];
}

#pragma mark - YZPixelBufferDelegate
- (void)buffer:(YZPixelBuffer *)buffer pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if ([_delegate respondsToSelector:@selector(video:pixelBuffer:)]) {
        [_delegate video:self pixelBuffer:pixelBuffer];
    }
}
@end
