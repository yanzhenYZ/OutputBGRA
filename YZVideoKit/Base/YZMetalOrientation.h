//
//  YZMetalOrientation.h
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MetalKit/MetalKit.h>

extern float *kYZColorConversion601;
extern float *kYZColorConversion601FullRange;
extern float *kYZColorConversion709;

typedef NS_ENUM(NSInteger, YZOrientation) {
    YZOrientationUnknown    = 0,
    YZOrientationPortrait   = 1,
    YZOrientationUpsideDown = 2,
    YZOrientationLeft       = 3,
    YZOrientationRight      = 4
};

@interface YZMetalOrientation : NSObject

+ (simd_float8)defaultVertices;
+ (simd_float8)defaultTextureCoordinates;
+ (simd_float8)getRotationTextureCoordinates:(int)rotation;

+ (simd_float8)getCropRotationTextureCoordinates:(int)rotation crop:(CGRect)crop;
@end
