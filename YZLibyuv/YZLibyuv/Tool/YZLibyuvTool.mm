//
//  YZLibyuvTool.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import "YZLibyuvTool.h"
#import "libyuv.h"

@implementation YZLibyuvTool
+ (void)ARGBRotate:(uint8_t *)srcBuffer srcStride:(int)srcStride dstBuffer:(uint8_t *)dstBuffer dstStride:(int)dstStride width:(int)width height:(int)height rotation:(int)rotation {
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

+ (void)NV12ToARGB:(uint8_t *)srcY strideY:(int)strideY srcUV:(uint8_t *)srcUV strideUV:(int)strideUV argbBuffer:(uint8_t *)argb strideARGB:(int)strideARGB width:(int)width height:(int)height {
    
    libyuv::NV12ToARGB(srcY, strideY, srcUV, strideUV, argb, strideARGB, width, height);
    
    //libyuv::I420ToBGRA(<#const uint8 *src_y#>, <#int src_stride_y#>, <#const uint8 *src_u#>, <#int src_stride_u#>, <#const uint8 *src_v#>, <#int src_stride_v#>, <#uint8 *dst_argb#>, <#int dst_stride_argb#>, <#int width#>, <#int height#>)
}
@end
