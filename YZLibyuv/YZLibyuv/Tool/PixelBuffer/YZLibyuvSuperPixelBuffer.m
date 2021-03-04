//
//  YZLibyuvSuperPixelBuffer.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/4.
//

#import <UIKit/UIKit.h>
#import "YZLibyuvSuperPixelBuffer.h"
#import "YZLibyuvPixelBuffer.h"
#import "YZLibVideoData.h"
#import "YZLibyuvTool.h"

@interface YZLibyuvSuperPixelBuffer ()
@property (nonatomic, strong) YZLibyuvPixelBuffer *buffer;
@end

@implementation YZLibyuvSuperPixelBuffer
- (void)setOutputBuffer:(YZLibyuvPixelBuffer *)buffer {
    _buffer = buffer;
}

- (void)inputVideoData:(YZLibVideoData *)videoData { }

#if 1 //裁剪问题这里不做裁剪
- (void)outputVideoData:(YZLibVideoData *)videoData pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [_buffer inputVideoData:videoData pixelBuffer:pixelBuffer];
}

- (void)outputPixelBuffer:(uint8_t *)buffer width:(int)width height:(int)height videoData:(YZLibVideoData *)data {
    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, buffer, width * 4, NULL, NULL, NULL, &pixelBuffer);
    if (pixelBuffer != NULL) {
        [_buffer inputVideoData:data pixelBuffer:pixelBuffer];
        CVPixelBufferRelease(pixelBuffer);
    }
}
#else
- (void)outputVideoData:(YZLibVideoData *)videoData pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [self cutPixelBuffer:pixelBuffer videoData:videoData];
}

- (void)outputPixelBuffer:(uint8_t *)buffer width:(int)width height:(int)height videoData:(YZLibVideoData *)data {
    UIEdgeInsets edge = [self getCropInsets:data];
    if (UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, edge)) {
        CVPixelBufferRef pixelBuffer = NULL;
        CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, buffer, width * 4, NULL, NULL, NULL, &pixelBuffer);
        if (pixelBuffer != NULL) {
            [_buffer inputVideoData:data pixelBuffer:pixelBuffer];
            CVPixelBufferRelease(pixelBuffer);
        }
        return;
    }
    
    size_t newWith = width - edge.left - edge.right;
    size_t newHeight = height - edge.top - edge.bottom;
    size_t bytesPerRow = width * 4;
    size_t startW = bytesPerRow / 8 - (width / 2 - edge.left);
    size_t start = edge.top * bytesPerRow + startW * 4;
    
    
    CVPixelBufferRef newPixelBuffer = nil;
    CVReturn status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, newWith, newHeight, kCVPixelFormatType_32BGRA, &buffer[start], bytesPerRow, NULL, NULL, NULL, &newPixelBuffer);
    if (status != 0)
    {
        return;
    }
    [_buffer inputVideoData:data pixelBuffer:newPixelBuffer];
    CVPixelBufferRelease(newPixelBuffer);
}
#endif

#pragma mark - helper
- (void)cutPixelBuffer:(CVPixelBufferRef)pixelBuffer videoData:(YZLibVideoData *)data {
    UIEdgeInsets edge = [self getCropInsets:data];
    if (UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, edge)) {
        [_buffer inputVideoData:data pixelBuffer:pixelBuffer];
        return;
    }
    [self doCutPixelBuffer:pixelBuffer edge:edge videoData:data];
}

- (void)doCutPixelBuffer:(CVPixelBufferRef)pixelBuffer edge:(UIEdgeInsets)edge videoData:(YZLibVideoData *)data {
    //大约3%~4%CPU
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t newWith = width - edge.left - edge.right;
    size_t newHeight = height - edge.top - edge.bottom;
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    //bytesPerRow / 4 / 2 = 中间点 ———— (width / 2 - edge.left)裁剪需要剩余的宽度
    //bytesPerRow / 8 != width / 2
    size_t startW = bytesPerRow / 8 - (width / 2 - edge.left);
    size_t start = edge.top * bytesPerRow + startW * 4;
    
    
    CVPixelBufferLockBaseAddress(pixelBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    
    CVPixelBufferRef newPixelBuffer = nil;
    CVReturn status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, newWith, newHeight, kCVPixelFormatType_32BGRA, &baseAddress[start], bytesPerRow, NULL, NULL, NULL, &newPixelBuffer);
    if (status != 0)
    {
        CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
        return;
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
    
    
    [_buffer inputVideoData:data pixelBuffer:newPixelBuffer];
    CVPixelBufferRelease(newPixelBuffer);
}

- (UIEdgeInsets)getCropInsets:(YZLibVideoData *)data {
    if (data.rotation == 90) {
        return UIEdgeInsetsMake(data.cropLeft, data.cropBottom, data.cropRight, data.cropTop);
    } else if (data.rotation == 180) {
        return UIEdgeInsetsMake(data.cropBottom, data.cropRight, data.cropTop, data.cropLeft);
    } else if (data.rotation == 270) {
        return UIEdgeInsetsMake(data.cropRight, data.cropTop, data.cropLeft, data.cropBottom);
    }
    return UIEdgeInsetsMake(data.cropTop, data.cropLeft, data.cropBottom, data.cropRight);
}
@end
