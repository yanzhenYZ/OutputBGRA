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

/** rotation
 90  4~5%CPU
 180 2%
 */
- (void)inputVideoData:(YZLibVideoData *)videoData {
    if (videoData.rotation == 0) {
        [_buffer inputVideoData:videoData pixelBuffer:videoData.pixelBuffer];
    } else {//todo
        CVPixelBufferRef pixelBuffer = videoData.pixelBuffer;
        int w = (int)CVPixelBufferGetWidth(pixelBuffer);
        int h = (int)CVPixelBufferGetHeight(pixelBuffer);
        int width = w;
        int height = h;
        if (videoData.rotation == 90 || videoData.rotation ==  270) {
            width = h;
            height = w;
        }
        
        uint8_t *buffer = malloc(width * height * 4);
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        uint8_t *srcBuffer = CVPixelBufferGetBaseAddress(pixelBuffer);
        int bytesPerrow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
        int dstStride = width * 4;
        
        //NSLog(@"123456___%d:%d:%d", bytesPerrow, bytesPerrow / 4, w);
        [YZLibyuvTool ARGBRotate:srcBuffer srcStride:bytesPerrow dstBuffer:buffer dstStride:dstStride width:w height:h rotation:videoData.rotation];
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
        
        CVPixelBufferRef newPixelBuffer = NULL;
        CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, buffer, width * 4, NULL, NULL, NULL, &newPixelBuffer);
        
        //NSLog(@"123456___%d:%d:%d", CVPixelBufferGetWidth(newPixelBuffer), CVPixelBufferGetHeight(newPixelBuffer), CVPixelBufferGetBytesPerRow(newPixelBuffer));
        
        if (pixelBuffer != NULL) {
            [_buffer inputVideoData:videoData pixelBuffer:newPixelBuffer];
            CVPixelBufferRelease(newPixelBuffer);
            free(buffer);
        }
    }
}
@end
