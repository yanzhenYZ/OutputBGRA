//
//  LibyuvBGRAPixelBuffer.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import "LibyuvBGRAPixelBuffer.h"
#import "YZLibyuvPixelBuffer.h"
#import "YZLibVideoData.h"

@interface LibyuvBGRAPixelBuffer ()
@property (nonatomic, strong) YZLibyuvPixelBuffer *buffer;
@end

@implementation LibyuvBGRAPixelBuffer
- (void)setOutputBuffer:(YZLibyuvPixelBuffer *)buffer {
    _buffer = buffer;
}

- (void)inputVideoData:(YZLibVideoData *)videoData {
    if (videoData.rotation == 0) {
        [_buffer inputVideoData:videoData pixelBuffer:videoData.pixelBuffer];
    }
}
@end
