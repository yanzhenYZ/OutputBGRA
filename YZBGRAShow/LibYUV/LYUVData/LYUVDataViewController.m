//
//  LYUVDataViewController.m
//  YZBGRAShow
//
//  Created by yanzhen on 2021/3/4.
//

#import "LYUVDataViewController.h"
#import <YZLibyuv/YZLibyuv.h>
#import "YUVCapture.h"

@interface LYUVDataViewController ()<YZLibyuvDelegate, YUVCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *showPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *mainPlayer;

@property (nonatomic, strong) YUVCapture *capture;
@property (nonatomic, strong) YZLibyuv *libYUV;

@property (nonatomic, strong) CIContext *context;
@end

@implementation LYUVDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _context = [CIContext contextWithOptions:nil];
    
    _libYUV = [[YZLibyuv alloc] init];
    _libYUV.delegate = self;
    
    _capture = [[YUVCapture alloc] initWithPlayer:_mainPlayer];
    _capture.delegate = self;
    [_capture startRunning];
}

#pragma mark - YUVCaptureDelegate
- (void)capture:(YUVCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [self inputVideoData:pixelBuffer];
}

- (void)inputVideoData:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t yWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    size_t yheight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    int8_t *yBuffer = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    size_t yBytesPow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    //NSLog(@"___1234:%d:%d:%d", yWidth, yheight, yBytesPow);
    
    //size_t uvWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    size_t uvheight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    int8_t *uvBuffer = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    size_t uvBytesPow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    //NSLog(@"___1234:%d:%d:%d", uvWidth, uvheight, uvBytesPow);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    YZLibVideoData *data = [[YZLibVideoData alloc] init];
    data.width = (int)yWidth;
    data.height = (int)yheight;
    data.yStride = (int)yBytesPow;
    data.yBuffer = yBuffer;
    
    int8_t *uBuffer = malloc(uvBytesPow * uvheight / 2);
    int8_t *vBuffer = malloc(uvBytesPow * uvheight / 2);
    
    for (int i = 0; i < uvBytesPow * uvheight / 2; i++) {
        uBuffer[i] = uvBuffer[2*i];
        vBuffer[i] = uvBuffer[2*i+1];
    }
    
    data.uStride = uvBytesPow / 2;
    data.uBuffer = uBuffer;
    data.vStride = data.uStride;
    data.vBuffer = vBuffer;
    
#if 0
    if (CVPixelBufferGetHeight(pixelBuffer) == 480) {
        data.cropLeft = 60;
        data.cropRight = 60;
        data.cropTop = 60;
        data.cropBottom = 60;
    }
#endif
    
    data.rotation = [self getOutputRotation];
    [_libYUV inputVideoData:data];
    
    free(uBuffer);
    free(vBuffer);
    
}


#pragma mark - YZLibyuvDelegate
- (void)libyuv:(YZLibyuv *)yuv pixelBuffer:(CVPixelBufferRef)pixelBuffer {
//    [self showPixelBuffer:pixelBuffer];
}

#pragma mark - helper
- (void)showPixelBuffer:(CVPixelBufferRef)pixel {
    CVPixelBufferRetain(pixel);
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:pixel];
    size_t width = CVPixelBufferGetWidth(pixel);
    size_t height = CVPixelBufferGetHeight(pixel);
    CGImageRef videoImageRef = [_context createCGImage:ciImage fromRect:CGRectMake(0, 0, width, height)];
    UIImage *image = [UIImage imageWithCGImage:videoImageRef];
    CGImageRelease(videoImageRef);
    CVPixelBufferRelease(pixel);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.showPlayer.image = image;
    });
}

- (int)getOutputRotation {//test code
    int ratation = 0;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return 90;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return 270;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return 0;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return 180;
            break;
        default:
            break;
    }
    return ratation;
    
}

#pragma mark - ui
- (IBAction)exitCapture:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

@end
