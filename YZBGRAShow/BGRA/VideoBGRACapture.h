//
//  VideoBGRACapture.h
//  YZBGRAShow
//
//  Created by yanzhen on 2021/3/1.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

@protocol VideoBGRACaptureDelegate;
@interface VideoBGRACapture : NSObject
@property (nonatomic, weak) id<VideoBGRACaptureDelegate> delegate;

- (instancetype)initWithPlayer:(UIView *)player;

- (void)startRunning;
- (void)stopRunning;
@end

@protocol VideoBGRACaptureDelegate <NSObject>

- (void)capture:(VideoBGRACapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

