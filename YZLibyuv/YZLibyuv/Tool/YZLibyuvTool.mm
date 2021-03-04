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
    if (rotation == 90) {
        mode = libyuv::kRotate90;
    } else if (rotation == 180) {
        mode = libyuv::kRotate180;
    } else if (rotation == 270) {
        mode = libyuv::kRotate270;
    }
    libyuv::ARGBRotate(srcBuffer, srcStride, dstBuffer, dstStride, width, height, mode);
}

@end
