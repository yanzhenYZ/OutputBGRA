//
//  YZPixelBuffer.h
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <MetalKit/MetalKit.h>

@protocol YZPixelBufferDelegate;
@interface YZPixelBuffer : NSObject
@property (nonatomic, weak) id<YZPixelBufferDelegate> delegate;

- (void)newTextureAvailable:(id<MTLTexture>)texture;
- (void)outoutPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end

@protocol YZPixelBufferDelegate <NSObject>

- (void)buffer:(YZPixelBuffer *)buffer pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
