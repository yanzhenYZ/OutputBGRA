//
//  YZMetalOrientation.m
//  YZVideoKit
//
//  Created by yanzhen on 2021/3/1.
//

#import "YZMetalOrientation.h"

float YZColorConversion601Default[] = {
    1.164, 1.164,  1.164, 0.0,
    0.0,   -0.392, 2.017, 0.0,
    1.596, -0.813, 0.0,   0.0,
};

// BT.601 full range (ref: http://www.equasys.de/colorconversion.html)
float YZColorConversion601FullRangeDefault[] = {
    1.0, 1.0,    1.0,   0.0,
    0.0, -0.343, 1.765, 0.0,
    1.4, -0.711, 0.0,   0.0,
};

// BT.709, which is the standard for HDTV.
float YZColorConversion709Default[] = {
    1.164, 1.164,  1.164, 0.0,
    0.0,   -0.213, 2.112, 0.0,
    1.793, -0.533, 0.0,   0.0,
};


float *kYZColorConversion601 = YZColorConversion601Default;
float *kYZColorConversion601FullRange = YZColorConversion601FullRangeDefault;
float *kYZColorConversion709 = YZColorConversion709Default;

static const simd_float8 StandardVertices = {-1, 1, 1, 1, -1, -1, 1, -1};

static const simd_float8 YZNoRotation = {0, 0, 1, 0, 0, 1, 1, 1};
static const simd_float8 YZRotateCounterclockwise = {0, 1, 0, 0, 1, 1, 1, 0};
static const simd_float8 YZRotateClockwise = {1, 0, 1, 1, 0, 0, 0, 1};
static const simd_float8 YZRotate180 = {1, 1, 0, 1, 1, 0, 0, 0};
//static const simd_float8 YZFlipHorizontally = {1, 0, 0, 0, 1, 1, 0, 1};
//static const simd_float8 YZFlipVertically = {0, 1, 1, 1, 0, 0, 1, 0};
//static const simd_float8 YZRotateClockwiseAndFlipVertically = {0, 0, 0, 1, 1, 0, 1, 1};
//static const simd_float8 YZRotateClockwiseAndFlipHorizontally = {1, 1, 1, 0, 0, 1, 0, 0};

typedef NS_ENUM(NSInteger, YZRotation) {
    YZRotationNoRotation                         = 0,
    YZRotationRotate180                          = 1,
    YZRotationRotateCounterclockwise             = 2,
    YZRotationRotateClockwise                    = 3,
    YZRotationFlipHorizontally                   = 4,
    YZRotationFlipVertically                     = 5,
    YZRotationRotateClockwiseAndFlipVertically   = 6,
    YZRotationRotateClockwiseAndFlipHorizontally = 7
};


@implementation YZMetalOrientation

+ (simd_float8)defaultVertices {
    return StandardVertices;
}


+ (simd_float8)defaultTextureCoordinates {
    return YZNoRotation;
}

+ (simd_float8)getRotationTextureCoordinates:(int)rotation {
    switch (rotation) {
        case 90:
            return YZRotateCounterclockwise;
            break;
        case 180:
            return YZRotate180;
            break;
        case 270:
            return YZRotateClockwise;
            break;
        default:
            return YZNoRotation;
            break;
    }
}

+ (simd_float8)getCropRotationTextureCoordinates:(int)rotation crop:(CGRect)crop {
    if (CGRectEqualToRect(CGRectZero, crop)) {
        return [self getRotationTextureCoordinates:rotation];
    }
//    NSLog(@"1234___%@", NSStringFromCGRect(crop));
    CGFloat x = crop.origin.x;
    CGFloat y = crop.origin.y;
    CGFloat maxX = CGRectGetMaxX(crop);
    CGFloat maxY = CGRectGetMaxY(crop);
    switch (rotation) {
        case 90: {
            simd_float8 t = {x, maxY, x, y, maxX, maxY, maxX, y};
            return t;
        }
            break;
        case 180:{
            simd_float8 t = {maxX, maxY, x, maxY, maxX, y, x, y};
            return t;
        }
            break;
        case 270:{
            simd_float8 t = {maxX, y, maxX, maxY, x, y, x, maxY};
            return t;
        }
            break;
        default:{
            simd_float8 t = {x, y, maxX, y, x, maxY, maxX, maxY};
            return t;
        }
            break;
    }
}

@end
