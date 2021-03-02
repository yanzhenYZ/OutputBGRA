//
//  main.m
//  YZBGRAShow
//
//  Created by yanzhen on 2021/3/1.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
/**
 1.0.2 裁剪CVPixelBuffer
 1.0.3 branch 不支持Metal libyuv
 */
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
