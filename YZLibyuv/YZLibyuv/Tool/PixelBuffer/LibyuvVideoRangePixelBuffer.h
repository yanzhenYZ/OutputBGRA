//
//  LibyuvVideoRangePixelBuffer.h
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/4.
//

#import <Foundation/Foundation.h>

@class YZLibVideoData;
@class YZLibyuvPixelBuffer;
@interface LibyuvVideoRangePixelBuffer : NSObject
- (void)setOutputBuffer:(YZLibyuvPixelBuffer *)buffer;

- (void)inputVideoData:(YZLibVideoData *)videoData;

@end
