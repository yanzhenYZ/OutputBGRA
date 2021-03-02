//
//  YZPixelBuffer.h
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <MetalKit/MetalKit.h>

@class YZVideoData;
@protocol YZPixelBufferDelegate;
@interface YZPixelBuffer : NSObject
@property (nonatomic, weak) id<YZPixelBufferDelegate> delegate;

- (void)outoutPixelBuffer:(CVPixelBufferRef)pixelBuffer videoData:(YZVideoData *)data;
@end

@protocol YZPixelBufferDelegate <NSObject>

- (void)buffer:(YZPixelBuffer *)buffer pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
