//
//  LBGRAViewController.m
//  YZBGRAShow
//
//  Created by yanzhen on 2021/3/3.
//

#import "LBGRAViewController.h"
#import "VideoBGRACapture.h"
#import <YZLibyuv/YZLibyuv.h>

@interface LBGRAViewController ()<VideoBGRACaptureDelegate, YZLibyuvDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *mainPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *showPlayer;

@property (nonatomic, strong) VideoBGRACapture *capture;
@property (nonatomic, strong) YZLibyuv *libyuv;


@property (nonatomic, strong) CIContext *context;

@end

@implementation LBGRAViewController {
    CVPixelBufferRef _pixelBuffer;
}

- (void)dealloc {
    if (_pixelBuffer) {
        CVPixelBufferRelease(_pixelBuffer);
        _pixelBuffer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self test];
    _libyuv = [[YZLibyuv alloc] init];
    _libyuv.delegate = self;
    _context = [CIContext contextWithOptions:nil];
    
    _capture = [[VideoBGRACapture alloc] initWithPlayer:_mainPlayer];
    _capture.delegate = self;
    [_capture startRunning];
}

- (void)test {
    NSDictionary *pixelAttributes = @{(NSString *)kCVPixelBufferIOSurfacePropertiesKey:@{}};
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                            360,
                                            480,
                                            kCVPixelFormatType_32BGRA,
                                            (__bridge CFDictionaryRef)(pixelAttributes),
                                            &_pixelBuffer);
    if (result != kCVReturnSuccess) {
        NSLog(@"LBGRAViewController to create cvpixelbuffer %d", result);
        return;
    }
    int by = CVPixelBufferGetBytesPerRow(_pixelBuffer);
    NSLog(@"1234567____%d:%d", by, by / 4);
}

- (void)testPix:(CVPixelBufferRef)pixelBuffer {
    int width = 360;
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    NSInteger bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    CVPixelBufferRef newPixelBuffer = NULL;
    CVReturn status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, 480, kCVPixelFormatType_32BGRA, &baseAddress[(640 - 480) * 2], bytesPerRow, NULL, NULL, NULL, &newPixelBuffer);
    if (status != 0)
    {
        CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
        return;
    }
    [self inputPixelBuffer:newPixelBuffer];
//    NSLog(@"XXX____%d")
    CVPixelBufferRelease(newPixelBuffer);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

//测试bytesPerRow/4不等于width,步长问题
- (void)test2Buffer:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(_pixelBuffer, 0);
    size_t outBytesRow = CVPixelBufferGetBytesPerRow(_pixelBuffer);
    uint8_t *outAddress = CVPixelBufferGetBaseAddress(_pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t bytesRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    uint8_t *address = CVPixelBufferGetBaseAddress(pixelBuffer);
    int height = 480;
    size_t offset = (bytesRow - outBytesRow) / 2;
    for (int i = 0; i < height; i++) {
        memcpy(outAddress + i * outBytesRow, address + i * bytesRow + offset, outBytesRow);
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVPixelBufferUnlockBaseAddress(_pixelBuffer, 0);
    
//    [self showPixelBuffer:_pixelBuffer];
    [self inputPixelBuffer:_pixelBuffer];
}

#pragma mark - VideoBGRACaptureDelegate
- (void)capture:(VideoBGRACapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
//    [self inputPixelBuffer:pixelBuffer];
    //步长不等于bytesPerRow/4
//    [self testPix:pixelBuffer];
    [self test2Buffer:pixelBuffer];
}

- (void)inputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    YZLibVideoData *data = [[YZLibVideoData alloc] init];
    data.pixelBuffer = pixelBuffer;
#pragma mark - ROTATION__TEST && RRR11
#if 1//不设置AVCaptureConnection视频方向需要设置
    data.rotation = [self getOutputRotation];
#endif

//test
#if 0
    if (CVPixelBufferGetHeight(pixelBuffer) == 480) {
        data.cropLeft = 60;
        data.cropRight = 60;
        data.cropTop = 60;
        data.cropBottom = 60;
    }
#endif

    [_libyuv inputVideoData:data];
}

#pragma mark - YZLibyuvDelegate
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
