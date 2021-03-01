//
//  YZPixelBuffer.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import "YZPixelBuffer.h"

@implementation YZPixelBuffer

- (void)outoutPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if ([_delegate respondsToSelector:@selector(buffer:pixelBuffer:)]) {
        [_delegate buffer:self pixelBuffer:pixelBuffer];
    }
}

@end
