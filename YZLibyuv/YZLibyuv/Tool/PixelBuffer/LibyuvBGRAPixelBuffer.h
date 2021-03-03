//
//  LibyuvBGRAPixelBuffer.h
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import <Foundation/Foundation.h>

@class YZLibVideoData;
@class YZLibyuvPixelBuffer;
@interface LibyuvBGRAPixelBuffer : NSObject
- (void)setOutputBuffer:(YZLibyuvPixelBuffer *)buffer;

- (void)inputVideoData:(YZLibVideoData *)videoData;

@end

