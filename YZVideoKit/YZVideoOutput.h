//
//  YZVideoOutput.h
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YZVideoData;
@protocol YZVideoOutputDelegate;
@interface YZVideoOutput : NSObject

@property (nonatomic, weak) id<YZVideoOutputDelegate> delegate;

- (void)inputVideo:(YZVideoData *)videoData;

@end

@protocol YZVideoOutputDelegate <NSObject>
/** 输入CVPixelBufferRef， 不做裁剪，不做旋转，直接输出对应CVPixelBufferRef */
- (void)video:(YZVideoOutput *)video pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end


