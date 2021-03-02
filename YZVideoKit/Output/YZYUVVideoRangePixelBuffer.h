//
//  YZYUVVideoRangePixelBuffer.h
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/2.
//

#import <Foundation/Foundation.h>

@class YZVideoData;
@class YZPixelBuffer;
@interface YZYUVVideoRangePixelBuffer : NSObject

- (void)inputVideoData:(YZVideoData *)videoData;

- (void)setOutputPixelBuffer:(YZPixelBuffer *)pixelBuffer;

@end


