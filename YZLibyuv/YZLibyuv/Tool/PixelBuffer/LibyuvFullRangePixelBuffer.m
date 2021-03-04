//
//  LibyuvFullRangePixelBuffer.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/4.
//

#import "LibyuvFullRangePixelBuffer.h"
#import "YZLibyuvPixelBuffer.h"
#import "YZLibVideoData.h"
#import "YZLibyuvTool.h"

@interface LibyuvFullRangePixelBuffer ()
@property (nonatomic, strong) YZLibyuvPixelBuffer *buffer;
@end

@implementation LibyuvFullRangePixelBuffer

- (void)setOutputBuffer:(YZLibyuvPixelBuffer *)buffer {
    _buffer = buffer;
}
/**640x480 rotation
  0   CPU 2~3% 转BGRA
  90  CPU 6~7% 转BGRA+旋转
  180 CPU 4~5% 转BGRA+旋转
 */
- (void)inputVideoData:(YZLibVideoData *)videoData {
    CVPixelBufferRef pixelBuffer = videoData.pixelBuffer;
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    uint8_t *srcY = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    int strideY = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    uint8_t *srcUV = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    int strideUV = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    uint8_t *buffer = malloc(width * height * 4);
    
    [YZLibyuvTool NV12ToARGB:srcY strideY:strideY srcUV:srcUV strideUV:strideUV argbBuffer:buffer strideARGB:width * 4 width:width height:height];
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    if (videoData.rotation == 0) {
        CVPixelBufferRef newPixelBuffer = NULL;
        CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, buffer, width * 4, NULL, NULL, NULL, &newPixelBuffer);
        if (pixelBuffer != NULL) {
            [_buffer inputVideoData:videoData pixelBuffer:newPixelBuffer];
            CVPixelBufferRelease(newPixelBuffer);
        }
        free(buffer);
    } else {
        uint8_t *dstBuffer = malloc(width * height * 4);
        int dstW = width;
        int dstH = height;
        if (videoData.rotation == 90 || videoData.rotation == 270) {
            dstW = height;
            dstH = width;
        }
        [YZLibyuvTool ARGBRotate:buffer srcStride:width * 4 dstBuffer:dstBuffer dstStride:dstW * 4 width:width height:height rotation:videoData.rotation];
        
        CVPixelBufferRef newPixelBuffer = NULL;
        CVPixelBufferCreateWithBytes(kCFAllocatorDefault, dstW, dstH, kCVPixelFormatType_32BGRA, dstBuffer, dstW * 4, NULL, NULL, NULL, &newPixelBuffer);
        if (pixelBuffer != NULL) {
            [_buffer inputVideoData:videoData pixelBuffer:newPixelBuffer];
            CVPixelBufferRelease(newPixelBuffer);
        }
        free(buffer);
        free(dstBuffer);
    }
}

@end
