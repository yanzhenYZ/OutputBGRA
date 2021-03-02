//
//  TYUVCapture.h
//  YZBGRAShow
//
//  Created by yanzhen on 2021/3/2.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

@protocol TYUVCaptureDelegate;
@interface TYUVCapture : NSObject
@property (nonatomic, weak) id<TYUVCaptureDelegate> delegate;

- (instancetype)initWithPlayer:(UIView *)player;

- (void)startRunning;
- (void)stopRunning;
@end

@protocol TYUVCaptureDelegate <NSObject>

- (void)capture:(TYUVCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end



