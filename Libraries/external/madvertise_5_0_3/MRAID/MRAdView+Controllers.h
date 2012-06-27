//
//  MRAdView+Controllers.h
//  MoPub
//
//  Created by Andrew He on 12/22/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import "MRAdView.h"

@interface MRAdView (Controllers)

- (void)fireChangeEventForProperty:(MRProperty *)property;
- (void)fireChangeEventsForProperties:(NSArray *)properties;
- (void)fireErrorEventForAction:(NSString *)action withMessage:(NSString *)message;
- (void)fireReadyEvent;
- (void)fireNativeCommandCompleteEvent:(NSString *)command;

// Delegate callback methods wrapped with -respondsToSelector: checks.
- (void)adDidLoad;
- (void)adDidFailToLoad;
- (void)adWillClose;
- (void)adDidClose;
- (void)adWillHide;
- (void)adDidHide;
- (void)adDidRequestCustomCloseEnabled:(BOOL)enabled;
- (void)adWillExpandToFrame:(CGRect)frame;
- (void)adDidExpandToFrame:(CGRect)frame;
- (void)adWillPresentModalView;
- (void)adDidDismissModalView;
- (void)appShouldSuspend;
- (void)appShouldResume;
- (void)adViewableDidChange:(BOOL)viewable;

@end
