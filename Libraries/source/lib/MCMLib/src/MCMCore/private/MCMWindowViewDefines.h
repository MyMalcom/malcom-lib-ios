//
//  MCMWindowViewDefines.h
//  MalcomLibProject
//
//  Created by Guillermo Ceballos on 24/01/14.
//  Copyright (c) 2014 Malcom. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
typedef NS_OPTIONS(NSUInteger, AGInterfaceOrientationMask) {
    AGInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    AGInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    AGInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    AGInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
    AGInterfaceOrientationMaskLandscape = (AGInterfaceOrientationMaskLandscapeLeft | AGInterfaceOrientationMaskLandscapeRight),
    AGInterfaceOrientationMaskAll = (AGInterfaceOrientationMaskPortrait | AGInterfaceOrientationMaskLandscapeLeft | AGInterfaceOrientationMaskLandscapeRight | AGInterfaceOrientationMaskPortraitUpsideDown),
    AGInterfaceOrientationMaskAllButUpsideDown = (AGInterfaceOrientationMaskPortrait | AGInterfaceOrientationMaskLandscapeLeft | AGInterfaceOrientationMaskLandscapeRight),
};
#else
typedef NS_OPTIONS(NSUInteger, AGInterfaceOrientationMask) {
    AGInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    AGInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    AGInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    AGInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
    AGInterfaceOrientationMaskLandscape = (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
    AGInterfaceOrientationMaskAll = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
    AGInterfaceOrientationMaskAllButUpsideDown = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
};
#endif