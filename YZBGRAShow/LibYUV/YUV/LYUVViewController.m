//
//  LYUVViewController.m
//  YZBGRAShow
//
//  Created by yanzhen on 2021/3/4.
//

#import "LYUVViewController.h"
#import <YZLibyuv/YZLibyuv.h>
#import "YUVCapture.h"

@interface LYUVViewController ()<YZLibyuvDelegate, YUVCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *mainPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *showPlayer;

@property (nonatomic, strong) YUVCapture *capture;
@property (nonatomic, strong) YZLibyuv *libYUV;

@property (nonatomic, strong) CIContext *context;
@end

@implementation LYUVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _context = [CIContext contextWithOptions:nil];
    
    _libYUV = [[YZLibyuv alloc] init];
    _libYUV.delegate = self;
    
    _capture = [[YUVCapture alloc] initWithPlayer:_mainPlayer];
    _capture.delegate = self;
    [_capture startRunning];
}

#pragma mark - YUVCaptureDelegate
- (void)capture:(YUVCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    YZLibVideoData *data = [[YZLibVideoData alloc] init];
    data.pixelBuffer = pixelBuffer;
#pragma mark - ROTATION__TEST && RRR11
#if 1//不设置AVCaptureConnection视频方向需要设置
    data.rotation = [self getOutputRotation];
#endif
    
#if 0
    if (CVPixelBufferGetHeight(pixelBuffer) == 480) {
        data.cropLeft = 60;
        data.cropRight = 60;
        data.cropTop = 60;
        data.cropBottom = 60;
    }
#endif
    
    [_libYUV inputVideoData:data];
}

#pragma mark - YZLibyuvDelegate
- (void)libyuv:(YZLibyuv *)yuv pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [self showPixelBuffer:pixelBuffer];
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
