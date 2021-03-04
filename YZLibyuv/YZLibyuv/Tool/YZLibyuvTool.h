//
//  YZLibyuvTool.h
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import <Foundation/Foundation.h>

@interface YZLibyuvTool : NSObject

+ (void)ARGBRotate:(uint8_t *)srcBuffer srcStride:(int)srcStride dstBuffer:(uint8_t *)dstBuffer dstStride:(int)dstStride width:(int)width height:(int)height rotation:(int)rotation;

+ (void)NV12ToARGB:(uint8_t *)srcY strideY:(int)strideY srcUV:(uint8_t *)srcUV strideUV:(int)strideUV argbBuffer:(uint8_t *)argb strideARGB:(int)strideARGB width:(int)width height:(int)height;

+ (void)I420ToBGRA:(uint8_t *)srcY strideY:(int)strideY srcU:(uint8_t *)srcU strideU:(int)strideU srcV:(uint8_t *)srcV strideV:(int)strideV bgraBuffer:(uint8_t *)bgra strideARGB:(int)strideARGB width:(int)width height:(int)height;
@end

