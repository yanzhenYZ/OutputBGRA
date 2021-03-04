//
//  LibyuvYUVDataPixelBuffer.m
//  YZLibyuv
//
//  Created by yanzhen on 2021/3/4.
//

#import "LibyuvYUVDataPixelBuffer.h"
#import "YZLibyuvPixelBuffer.h"
#import "YZLibVideoData.h"
#import "YZLibyuvTool.h"

@interface LibyuvYUVDataPixelBuffer ()
@property (nonatomic, strong) YZLibyuvPixelBuffer *buffer;
@end

@implementation LibyuvYUVDataPixelBuffer
-(void)setOutputBuffer:(YZLibyuvPixelBuffer *)buffer {
    _buffer = buffer;
}

-(void)inputVideoData:(YZLibVideoData *)videoData {
    uint8_t *buffer = malloc(videoData.width * videoData.height * 4);
    if (videoData.rotation == 0) {
        [YZLibyuvTool I420ToBGRA:videoData.yBuffer strideY:videoData.yStride srcU:videoData.uBuffer strideU:videoData.uStride srcV:videoData.vBuffer strideV:videoData.vStride bgraBuffer:buffer strideARGB:videoData.width * 4 width:videoData.width height:videoData.height];
        CVPixelBufferRef newPixelBuffer = NULL;
        CVPixelBufferCreateWithBytes(kCFAllocatorDefault, videoData.width, videoData.height, kCVPixelFormatType_32BGRA, buffer, videoData.width * 4, NULL, NULL, NULL, &newPixelBuffer);
        if (newPixelBuffer != NULL) {
            [_buffer inputVideoData:videoData pixelBuffer:newPixelBuffer];
            CVPixelBufferRelease(newPixelBuffer);
        }
    }
    free(buffer);
}
@end
