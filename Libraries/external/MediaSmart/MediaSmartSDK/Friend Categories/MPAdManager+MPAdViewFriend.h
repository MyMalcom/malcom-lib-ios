//
//  MPAdManager+MPAdViewFriend.h
//  MoPub
//
//  Created by Andrew He on 7/13/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPAdManager.h"

@interface MPAdManager (MPAdViewFriend)

@property (nonatomic, assign) MPAdView *adView;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, copy) NSURL *failURL;
@property (nonatomic, retain) NSMutableSet *webviewPool;
@property (nonatomic, retain) MPBaseAdapter *currentAdapter;
@property (nonatomic, assign) BOOL ignoresAutorefresh;

- (id)init;
- (void)removeWebviewFromPool:(UIWebView *)webview;
- (void)loadAdWithURL:(NSURL *)URL;
- (void)refreshAd;
- (void)forceRefreshAd;
- (void)trackImpression;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;
- (void)customEventDidLoadAd;
- (void)customEventDidFailToLoadAd;
- (void)customEventActionWillBegin;
- (void)customEventActionDidEnd;
- (void)updateOrientationPropertiesForWebView:(UIWebView *)webview;

@end
