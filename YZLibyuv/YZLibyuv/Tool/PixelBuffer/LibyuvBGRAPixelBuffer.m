//
//  LibyuvBGRAPixelBuffer.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import "LibyuvBGRAPixelBuffer.h"
#import "YZLibVideoData.h"
#import "YZLibyuvTool.h"

@implementation LibyuvBGRAPixelBuffer

/** rotation
 90  4~5%CPU
 180 2%
 */
- (void)inputVideoData:(YZLibVideoData *)videoData {
    if (videoData.rotation == 0) {
        [self outputVideoData:videoData pixelBuffer:videoData.pixelBuffer];
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
        
        [YZLibyuvTool ARGBRotate:srcBuffer srcStride:bytesPerrow dstBuffer:buffer dstStride:dstStride width:w height:h rotation:videoData.rotation];
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        [self outputPixelBuffer:buffer width:width height:height videoData:videoData];
        free(buffer);
    }
}
@end
