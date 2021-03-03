//
//  LibyuvBGRAPixelBuffer.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import "LibyuvBGRAPixelBuffer.h"
#import "YZLibyuvPixelBuffer.h"
#import "YZLibVideoData.h"
#import "YZLibyuvTool.h"

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
    } else {//todo
        CVPixelBufferRef pixelBuffer = videoData.pixelBuffer;
        size_t width = CVPixelBufferGetWidth(pixelBuffer);
        size_t height = CVPixelBufferGetHeight(pixelBuffer);
        uint8_t *buffer = malloc(width * height * 4);
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        uint8_t *srcBuffer = CVPixelBufferGetBaseAddress(pixelBuffer);
        size_t bytesPerrow = CVPixelBufferGetBytesPerRow(pixelBuffer);
        size_t dstStride = width * 4;
        int pw = width;
        int ph = height;
        if (videoData.rotation == 90 || videoData.rotation == 270) {
            pw = height;
            ph = width;
            dstStride = height * 4;
        }
        [YZLibyuvTool ARGBRotate:srcBuffer srcStride:bytesPerrow / 4 dstBuffer:buffer dstStride:dstStride width:width height:height rotation:videoData.rotation];
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
        
        CVPixelBufferRef newPixelBuffer = NULL;
        CVPixelBufferCreateWithBytes(kCFAllocatorDefault, pw, ph, kCVPixelFormatType_32BGRA, buffer, pw * 4,
                                     NULL, NULL, NULL, &newPixelBuffer);
        if (pixelBuffer != NULL) {
            [_buffer inputVideoData:videoData pixelBuffer:newPixelBuffer];
            CVPixelBufferRelease(newPixelBuffer);
            free(buffer);
        }
    }
}
@end
