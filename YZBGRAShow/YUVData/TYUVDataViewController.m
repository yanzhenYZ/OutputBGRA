//
//  TYUVDataViewController.m
//  YZBGRAShow
//
//  Created by yanzhen on 2021/3/2.
//

#import "TYUVDataViewController.h"
#import <YZVideoKit/YZVideoKit.h>
#import "TYUVDataCapture.h"

@interface TYUVDataViewController ()<TYUVDataCaptureDelegate, YZVideoOutputDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *mainPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *showPlayer;

@property (nonatomic, strong) TYUVDataCapture *capture;
@property (nonatomic, strong) YZVideoOutput *videoOutput;

@property (nonatomic, strong) CIContext *context;
@end

@implementation TYUVDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _context = [CIContext contextWithOptions:nil];

    _videoOutput = [[YZVideoOutput alloc] init];
    _videoOutput.delegate = self;

    _capture = [[TYUVDataCapture alloc] initWithPlayer:_mainPlayer];
    _capture.delegate = self;
    [_capture startRunning];
    
//    [self testBuffer];
}

- (void)testBuffer {
    CVPixelBufferRef pixelBuffer;
    OSStatus status = CVPixelBufferCreate(kCFAllocatorDefault, 480, 640, kCVPixelFormatType_420YpCbCr8Planar, nil, &pixelBuffer);
    if (status != noErr) {
        NSLog(@"CCC EERRR: %d", status);
        return;
    }
    
    //NSLog(@"___%d", CVPixelBufferGetPlaneCount(pixelBuffer));
    //512:256:256 bytes pow row
    //640:320:320
    //480:240:240
    
    //NSLog(@"---:%d:%d:%d", CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0), CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1), CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 2));
//    (<#CVPixelBufferRef  _Nonnull pixelBuffer#>, <#size_t planeIndex#>)
//    NSLog(@"---:%d:%d:%d", CVPixelBufferGetHeightOfPlane(pixelBuffer, 0), CVPixelBufferGetHeightOfPlane(pixelBuffer, 1), CVPixelBufferGetHeightOfPlane(pixelBuffer, 2));
//    NSLog(@"---:%d:%d:%d", CVPixelBufferGetWidthOfPlane(pixelBuffer, 0), CVPixelBufferGetWidthOfPlane(pixelBuffer, 1), CVPixelBufferGetWidthOfPlane(pixelBuffer, 2));
    
    //CVPixelBufferGetBytesPerRowOfPlane(<#CVPixelBufferRef  _Nonnull pixelBuffer#>, <#size_t planeIndex#>)
    CVPixelBufferRelease(pixelBuffer);
    
    
}

#pragma mark - YUVCaptureDelegate
- (void)capture:(TYUVDataCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [self inputVideoData:pixelBuffer];
}

- (void)inputVideoData:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t yWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    size_t yheight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    int8_t *yBuffer = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    size_t yBytesPow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    //NSLog(@"___1234:%d:%d:%d", yWidth, yheight, yBytesPow);
    
    size_t uvWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    size_t uvheight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    int8_t *uvBuffer = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    size_t uvBytesPow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    //NSLog(@"___1234:%d:%d:%d", uvWidth, uvheight, uvBytesPow);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    YZVideoData *data = [[YZVideoData alloc] init];
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
    data.vStride = uvBytesPow / 2;
    data.vBuffer = vBuffer;
    
#if 1
    if (CVPixelBufferGetWidth(pixelBuffer) == 480) {
        data.cropLeft = 60;
        data.cropRight = 60;
    } else {
        data.cropTop = 60;
        data.cropBottom = 60;
    }
#endif
    
    data.rotation = [self getOutputRotation];
    [_videoOutput inputVideo:data];
    
    free(uBuffer);
    free(vBuffer);
    
}

#pragma mark - YZVideoOutputDelegate
- (void)video:(YZVideoOutput *)video pixelBuffer:(CVPixelBufferRef)pixelBuffer {
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

#pragma mark - UI
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
