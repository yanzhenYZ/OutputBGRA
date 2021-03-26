//
//  YZYUVDataPixelBuffer.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/2.
//

#import "YZYUVDataPixelBuffer.h"
#import "YZMetalOrientation.h"
#import "YZMetalDevice.h"
#import "YZVideoData.h"

@implementation YZYUVDataPixelBuffer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pipelineState = [YZMetalDevice.defaultDevice newRenderPipeline:@"YZYUVDataToRGBVertex" fragment:@"YZYUVDataConversionFullRangeFragment"];
    }
    return self;
}

//CPU 3%
- (void)inputVideo:(YZVideoData *)videoData {
    int width = videoData.width;
    int height = videoData.height;
    if (![self cropTextureSize:CGSizeMake(width, height) videoData:videoData]) {
        return;
    }
    
    MTLTextureDescriptor *yDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width height:height mipmapped:NO];
    yDesc.usage = MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    id<MTLTexture> textureY = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:yDesc];
    [textureY replaceRegion:MTLRegionMake2D(0, 0, textureY.width, textureY.height) mipmapLevel:0 withBytes:videoData.yBuffer bytesPerRow:videoData.yStride];
    
    MTLTextureDescriptor *uDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width / 2 height:height / 2 mipmapped:NO];
    uDesc.usage = MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    id<MTLTexture> textureU = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:uDesc];
    [textureU replaceRegion:MTLRegionMake2D(0, 0, textureU.width, textureU.height) mipmapLevel:0 withBytes:videoData.uBuffer bytesPerRow:videoData.uStride];
    
    MTLTextureDescriptor *vDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width / 2 height:height / 2 mipmapped:NO];
    vDesc.usage = MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    id<MTLTexture> textureV = [YZMetalDevice.defaultDevice.device newTextureWithDescriptor:vDesc];
    [textureV replaceRegion:MTLRegionMake2D(0, 0, textureV.width, textureV.height) mipmapLevel:0 withBytes:videoData.vBuffer bytesPerRow:videoData.vStride];
    //
    MTLRenderPassDescriptor *desc = [YZMetalDevice newRenderPassDescriptor:self.texture];
    id<MTLCommandBuffer> commandBuffer = [YZMetalDevice.defaultDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZYUVDataPixelBuffer render endcoder Fail");
        return;
    }
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];
    
    simd_float8 vertices = [YZMetalOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    CGRect crop = [self getCropWith:CGSizeMake(width, height) videoData:videoData];
    simd_float8 textureCoordinates = [YZMetalOrientation getCropRotationTextureCoordinates:videoData.rotation crop:crop];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    //encoder setFragmentBytes:<#(nonnull const void *)#> length:<#(NSUInteger)#> atIndex:<#(NSUInteger)#>
    [encoder setFragmentTexture:textureY atIndex:0];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:2];
    [encoder setFragmentTexture:textureU atIndex:1];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:3];
    [encoder setFragmentTexture:textureV atIndex:2];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    [self outoutVideoData:videoData];
}

@end

