//
//  YZCropFilter.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import "YZCropFilter.h"
#import <MetalKit/MetalKit.h>
#import "YZPixelBuffer.h"
#import "YZVideoData.h"
#import "YZMetalDevice.h"
#import "YZMetalOrientation.h"
#import "YZBGRAPixelBuffer.h"
#import "YZYUVPixelBuffer.h"

@interface YZCropFilter ()
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;

@property (nonatomic, strong) YZPixelBuffer *pixelBuffer;
@property (nonatomic, strong) YZBGRAPixelBuffer *bgraBuffer;
@end

@implementation YZCropFilter
- (void)dealloc
{
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
        _textureCache = nil;
    }
}

- (YZBGRAPixelBuffer *)bgraBuffer {
    if (!_bgraBuffer) {
        _bgraBuffer = [[YZBGRAPixelBuffer alloc] init];
        [_bgraBuffer setOutputPixelBuffer:_pixelBuffer];
    }
    return _bgraBuffer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CVMetalTextureCacheCreate(NULL, NULL, YZMetalDevice.defaultDevice.device, NULL, &_textureCache);
        _pipelineState = [YZMetalDevice.defaultDevice newRenderPipeline:@"YZInputVertex" fragment:@"YZFragment"];
    }
    return self;
}

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
            [self.bgraBuffer inputVideo:videoData];
        }
    } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        if (videoData.rotation == 0) {
            //NSLog(@"todo");
        } else {
            
        }
    }
}





//no use
- (void)rotation32BGRA:(CVPixelBufferRef)pixelBuffer rotation:(int)rotation {
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    CVMetalTextureRef tmpTexture = NULL;
    CVReturn status =  CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tmpTexture);
    if (status != kCVReturnSuccess) {
        return;
    }
    
    id<MTLTexture> texture = CVMetalTextureGetTexture(tmpTexture);
    CFRelease(tmpTexture);

    NSUInteger outputW = width;
    NSUInteger outputH = height;
    if (rotation == 90 || rotation == 270) {
        outputW = height;
        outputH = width;
    }
    
    //output texture
    MTLTextureDescriptor *textureDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:outputW height:outputH mipmapped:NO];
    textureDesc.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget;
    id<MTLTexture> outputTexture = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:textureDesc];
    
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:outputTexture];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZCropFilter render endcoder Fail");
        return;
    }
    
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    simd_float8 vertices = [YZMetalOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = [YZMetalOrientation getRotationTextureCoordinates:rotation];
   
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:texture atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    
    [_pixelBuffer newTextureAvailable:outputTexture];
}
@end
