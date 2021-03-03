//
//  YZLibyuvPixelBuffer.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import "YZLibyuvPixelBuffer.h"

@implementation YZLibyuvPixelBuffer

- (void)inputVideoData:(YZLibVideoData *)videoData pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if ([_delegate respondsToSelector:@selector(buffer:pixelBuffer:)]) {
        [_delegate buffer:self pixelBuffer:pixelBuffer];
    }
}

@end
