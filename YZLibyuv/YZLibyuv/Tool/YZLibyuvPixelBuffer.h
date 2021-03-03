//
//  YZLibyuvPixelBuffer.h
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>

@class YZLibVideoData;
@protocol YZLibyuvPixelBufferDelegate;
@interface YZLibyuvPixelBuffer : NSObject
@property (nonatomic, assign) id<YZLibyuvPixelBufferDelegate> delegate;

- (void)inputVideoData:(YZLibVideoData *)videoData pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

@protocol YZLibyuvPixelBufferDelegate <NSObject>

- (void)buffer:(YZLibyuvPixelBuffer *)buffer pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

