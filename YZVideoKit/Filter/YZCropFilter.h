//
//  YZCropFilter.h
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import <Foundation/Foundation.h>

@class YZVideoData;
@class YZPixelBuffer;
@interface YZCropFilter : NSObject
- (void)setOutputPixelBuffer:(YZPixelBuffer *)pixelBuffer;

- (void)inputVideo:(YZVideoData *)videoData;

@end


