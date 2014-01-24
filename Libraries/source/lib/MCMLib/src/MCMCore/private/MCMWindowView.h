//
//  MCMWindowView.h
//  MalcomLibProject
//
//  Created by Guillermo Ceballos on 24/01/14.
//  Copyright (c) 2014 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MCMWindowViewDefines.h"

@interface MCMWindowView : UIView

@property (nonatomic, assign) AGInterfaceOrientationMask supportedInterfaceOrientations;

/**
 * @property UIViewController *controller. Convinience for having a strong reference to your controller.
 */
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, copy) void (^onDidMoveToWindow)(void);
@property (nonatomic, copy) void (^onDidMoveOutOfWindow)(void);

- (id)initAndAddToWindow:(UIWindow *)window;
- (id)initAndAddToKeyWindow;

- (void)addSubViewAndKeepSamePosition:(UIView *)view;
- (void)addSubviewAndFillBounds:(UIView *)view;
- (void)addSubviewAndFillBounds:(UIView *)view withSlideUpAnimationOnDone:(void(^)(void))onDone;
- (void)fadeOutAndRemoveFromSuperview:(void(^)(void))onDone;
- (void)slideDownSubviewsAndRemoveFromSuperview:(void(^)(void))onDone;

- (void)bringToFront;
- (BOOL)isInFront;

+ (NSArray *)allActiveWindowViews;
+ (MCMWindowView *)firstActiveWindowViewPassingTest:(BOOL (^)(MCMWindowView *windowView, BOOL *stop))test;
+ (MCMWindowView *)activeWindowViewForController:(UIViewController *)controller;
+ (MCMWindowView *)activeWindowViewContainingView:(UIView *)view;

@end

@interface MCMWindowViewHelper : NSObject

BOOL UIInterfaceOrientationsIsForSameAxis(UIInterfaceOrientation o1, UIInterfaceOrientation o2);
CGFloat UIInterfaceOrientationAngleBetween(UIInterfaceOrientation o1, UIInterfaceOrientation o2);
CGFloat UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation);
AGInterfaceOrientationMask AGInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation);

@end