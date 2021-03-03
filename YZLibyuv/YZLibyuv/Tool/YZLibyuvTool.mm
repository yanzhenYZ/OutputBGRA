//
//  YZLibyuvTool.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import "YZLibyuvTool.h"
#import "libyuv.h"

@implementation YZLibyuvTool
+ (void)ARGBRotate:(uint8 *)srcBuffer srcStride:(int)srcStride dstBuffer:(uint8_t *)dstBuffer dstStride:(int)dstStride width:(int)width height:(int)height rotation:(int)rotation {
    libyuv::RotationMode mode = libyuv::kRotate0;
    int dstW = width;
    int dstHeight = height;
    if (rotation == 90) {
        mode = libyuv::kRotate90;
    } else if (rotation == 180) {
        mode = libyuv::kRotate180;
    } else if (rotation == 270) {
        mode = libyuv::kRotate0;
    }
    libyuv::ARGBRotate(srcBuffer, srcStride, dstBuffer, dstStride, dstW, dstHeight, mode);
}

@end
