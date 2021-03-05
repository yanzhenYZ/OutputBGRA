//
//  BGRAToI420ViewController.m
//  YZBGRAShow
//
//  Created by yanzhen on 2021/3/4.
//

#import "BGRAToI420ViewController.h"
#import "VideoBGRACapture.h"
#import <YZLibyuv/YZLibyuv.h>

@interface BGRAToI420ViewController ()<VideoBGRACaptureDelegate, YZLibyuvDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *mainPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *showPlayer;

@property (nonatomic, strong) YZLibyuv *libyuv;
@property (nonatomic, strong) VideoBGRACapture *capture;
@property (nonatomic, strong) CIContext *context;
@end

@implementation BGRAToI420ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _context = [CIContext contextWithOptions:nil];
    _libyuv = [[YZLibyuv alloc] init];
    _libyuv.delegate = self;
    
    _capture = [[VideoBGRACapture alloc] initWithPlayer:_mainPlayer];
    _capture.delegate = self;
    [_capture startRunning];
}

#pragma mark - VideoBGRACaptureDelegate
- (void)capture:(VideoBGRACapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    int bgraStride = CVPixelBufferGetBytesPerRow(pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    uint8_t *bgra = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    uint8_t *y = malloc(width * height);
    uint8_t *u = malloc(width * height / 4);
    uint8_t *v = malloc(width * height / 4);
    [YZLibyuv BGRAToI420:bgra bgraStride:bgraStride dstY:y strideY:width dstU:u strideU:width / 2 dstV:v strideV:width / 2 width:width height:height];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    YZLibVideoData *data = [[YZLibVideoData alloc] init];
    data.width = width;
    data.height = height;
    data.yStride = width;
    data.yBuffer = y;
    
    data.uStride = width / 2;
    data.uBuffer = u;
    data.vStride = data.uStride;
    data.vBuffer = v;
    
#if 0
    if (CVPixelBufferGetHeight(pixelBuffer) == 480) {
        data.cropLeft = 60;
        data.cropRight = 60;
        data.cropTop = 60;
        data.cropBottom = 60;
    }
#endif
    
    data.rotation = [self getOutputRotation];
    [_libyuv inputVideoData:data];
    
    free(y);
    free(u);
    free(v);
}

-(void)libyuv:(YZLibyuv *)yuv pixelBuffer:(CVPixelBufferRef)pixelBuffer {
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
