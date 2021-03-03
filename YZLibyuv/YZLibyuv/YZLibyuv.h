//
//  YZLibyuv.h
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/3.
//

#import <Foundation/Foundation.h>
#import "YZLibVideoData.h"

@protocol YZLibyuvDelegate;
@interface YZLibyuv : NSObject
@property (nonatomic, assign) id<YZLibyuvDelegate> delegate;

- (void)inputVideoData:(YZLibVideoData *)videoData;

@end

@protocol YZLibyuvDelegate <NSObject>

- (void)libyuv:(YZLibyuv *)yuv pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
