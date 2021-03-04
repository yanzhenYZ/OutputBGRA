//
//  LibyuvYUVDataPixelBuffer.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/4.
//

#import "LibyuvYUVDataPixelBuffer.h"
#import "YZLibVideoData.h"
#import "YZLibyuvTool.h"

@implementation LibyuvYUVDataPixelBuffer

-(void)inputVideoData:(YZLibVideoData *)videoData {
    int width = videoData.width;
    int height = videoData.height;
    uint8_t *buffer = malloc(width * height * 4);
    [YZLibyuvTool I420ToBGRA:(uint8_t *)videoData.yBuffer strideY:videoData.yStride srcU:(uint8_t *)videoData.uBuffer strideU:videoData.uStride srcV:(uint8_t *)videoData.vBuffer strideV:videoData.vStride bgraBuffer:buffer strideARGB:width * 4 width:width height:height];
    if (videoData.rotation == 0) {
        [self outputPixelBuffer:buffer width:width height:height videoData:videoData];
    } else {
        uint8_t *dstBuffer = malloc(videoData.width * videoData.height * 4);
        int dstW = width;
        int dstH = height;
        if (videoData.rotation == 90 || videoData.rotation == 270) {
            dstW = height;
            dstH = width;
        }
        [YZLibyuvTool ARGBRotate:buffer srcStride:width * 4 dstBuffer:dstBuffer dstStride:dstW * 4 width:width height:height rotation:videoData.rotation];
        [self outputPixelBuffer:dstBuffer width:dstW height:dstH videoData:videoData];
        free(dstBuffer);
    }
    free(buffer);
}
@end
