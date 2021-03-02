//
//  TYUVDataCapture.h
//  YZBGRAShow
//
//  Created by yanzhen on 2021/3/2.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

@protocol TYUVDataCaptureDelegate;
@interface TYUVDataCapture : NSObject
@property (nonatomic, weak) id<TYUVDataCaptureDelegate> delegate;

- (instancetype)initWithPlayer:(UIView *)player;

- (void)startRunning;
- (void)stopRunning;
@end

@protocol TYUVDataCaptureDelegate <NSObject>

- (void)capture:(TYUVDataCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end


