//
//  YUVCapture.h
//  YZBGRAShow
//
//  Created by yanzhen on 2021/3/2.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

@protocol YUVCaptureDelegate;
@interface YUVCapture : NSObject
@property (nonatomic, weak) id<YUVCaptureDelegate> delegate;

- (instancetype)initWithPlayer:(UIView *)player;

- (void)startRunning;
- (void)stopRunning;
@end

@protocol YUVCaptureDelegate <NSObject>

- (void)capture:(YUVCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end


