//
//  YZBGRAPixelBuffer.h
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import <Foundation/Foundation.h>

@class YZVideoData;
@class YZPixelBuffer;
@interface YZBGRAPixelBuffer : NSObject

- (void)inputVideo:(YZVideoData *)videoData;

- (void)setOutputPixelBuffer:(YZPixelBuffer *)pixelBuffer;
@end


