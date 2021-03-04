//
//  LibyuvFullRangePixelBuffer.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/4.
//

#import "LibyuvFullRangePixelBuffer.h"
#import "YZLibyuvPixelBuffer.h"
#import "YZLibVideoData.h"

@interface LibyuvFullRangePixelBuffer ()
@property (nonatomic, strong) YZLibyuvPixelBuffer *buffer;
@end

@implementation LibyuvFullRangePixelBuffer

- (void)setOutputBuffer:(YZLibyuvPixelBuffer *)buffer {
    _buffer = buffer;
}

- (void)inputVideoData:(YZLibVideoData *)videoData {
    NSLog(@"___V:");
}
@end
