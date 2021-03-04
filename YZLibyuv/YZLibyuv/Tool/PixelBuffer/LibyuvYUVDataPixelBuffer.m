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
    NSLog(@"todo1");
}
@end
