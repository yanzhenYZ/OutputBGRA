//
//  YZPixelBuffer.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import "YZPixelBuffer.h"
#import "YZMetalDevice.h"
#import "YZMetalOrientation.h"
#import "YZVideoData.h"

@interface YZPixelBuffer ()

@end

@implementation YZPixelBuffer

- (void)outoutPixelBuffer:(CVPixelBufferRef)pixelBuffer videoData:(YZVideoData *)data {
    //[self cutPixelBuffer:pixelBuffer videoData:data];//BGRA cut
    if ([_delegate respondsToSelector:@selector(buffer:pixelBuffer:)]) {
        [_delegate buffer:self pixelBuffer:pixelBuffer];
    }
}

#pragma mark - helper
- (void)cutPixelBuffer:(CVPixelBufferRef)pixelBuffer videoData:(YZVideoData *)data {
    UIEdgeInsets edge = [self getCropInsets:data];
    if (UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, edge)) {
        if ([_delegate respondsToSelector:@selector(buffer:pixelBuffer:)]) {
            [_delegate buffer:self pixelBuffer:pixelBuffer];
        }
        return;
    }
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
    
    
    if ([_delegate respondsToSelector:@selector(buffer:pixelBuffer:)]) {
        [_delegate buffer:self pixelBuffer:newPixelBuffer];
    }
    CVPixelBufferRelease(newPixelBuffer);
}

- (UIEdgeInsets)getCropInsets:(YZVideoData *)data {
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
