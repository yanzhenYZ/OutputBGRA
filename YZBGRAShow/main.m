//
//  main.m
//  YZBGRAShow
//
//  Created by yanzhen on 2021/3/1.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
/**
 1. YUV三个buffer
 2. 裁剪CVPixelBuffer
 3. branch 不支持Metal
 */
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
