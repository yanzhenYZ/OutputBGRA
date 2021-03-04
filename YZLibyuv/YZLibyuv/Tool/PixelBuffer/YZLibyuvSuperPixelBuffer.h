//
//  YZLibyuvSuperPixelBuffer.h
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/4.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>

@class YZLibVideoData;
@class YZLibyuvPixelBuffer;
@interface YZLibyuvSuperPixelBuffer : NSObject

- (void)setOutputBuffer:(YZLibyuvPixelBuffer *)buffer;
- (void)inputVideoData:(YZLibVideoData *)videoData;

- (void)outputVideoData:(YZLibVideoData *)videoData pixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)outputPixelBuffer:(uint8_t *)buffer width:(int)width height:(int)height videoData:(YZLibVideoData *)data;
@end


