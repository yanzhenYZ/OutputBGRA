//
//  YZCropFilter.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import "YZCropFilter.h"
#import "YZPixelBuffer.h"
#import "YZVideoData.h"

@interface YZCropFilter ()
@property (nonatomic, strong) YZPixelBuffer *pixelBuffer;
@end

@implementation YZCropFilter
- (void)setOutputPixelBuffer:(YZPixelBuffer *)pixelBuffer {
    _pixelBuffer = pixelBuffer;
}

- (void)inputVideo:(YZVideoData *)videoData {
    if (videoData.pixelBuffer) {
        [self dealPixelBuffer:videoData];
    } else {
        
    }
}
#pragma mark - helper
- (void)dealPixelBuffer:(YZVideoData *)videoData {
    OSType type = CVPixelBufferGetPixelFormatType(videoData.pixelBuffer);
    if (type == kCVPixelFormatType_32BGRA) {
        if (videoData.rotation == 0) {
            [_pixelBuffer outoutPixelBuffer:videoData.pixelBuffer];
        } else {
            
        }
    } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        if (videoData.rotation == 0) {
            
        } else {
            
        }
    }
}
@end
