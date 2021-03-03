//
//  YZLibyuvTool.h
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import <Foundation/Foundation.h>

@interface YZLibyuvTool : NSObject

+ (void)ARGBRotate:(uint8_t *)srcBuffer srcStride:(int)srcStride dstBuffer:(uint8_t *)dstBuffer dstStride:(int)dstStride width:(int)width height:(int)height rotation:(int)rotation;

@end

