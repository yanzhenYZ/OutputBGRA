//
//  YZLibyuvSuperPixelBuffer.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/4.
//

#import "YZLibyuvSuperPixelBuffer.h"
#import "YZLibyuvPixelBuffer.h"
#import "YZLibVideoData.h"
#import "YZLibyuvTool.h"

@interface YZLibyuvSuperPixelBuffer ()
@property (nonatomic, strong) YZLibyuvPixelBuffer *buffer;
@end

@implementation YZLibyuvSuperPixelBuffer
- (void)setOutputBuffer:(YZLibyuvPixelBuffer *)buffer {
    _buffer = buffer;
}

- (void)inputVideoData:(YZLibVideoData *)videoData { }

- (void)outputVideoData:(YZLibVideoData *)videoData pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [_buffer inputVideoData:videoData pixelBuffer:pixelBuffer];
}

- (void)outputPixelBuffer:(uint8_t *)buffer width:(int)width height:(int)height videoData:(YZLibVideoData *)data {
    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, buffer, width * 4, NULL, NULL, NULL, &pixelBuffer);
    if (pixelBuffer != NULL) {
        [_buffer inputVideoData:data pixelBuffer:pixelBuffer];
        CVPixelBufferRelease(pixelBuffer);
    }
}
@end
