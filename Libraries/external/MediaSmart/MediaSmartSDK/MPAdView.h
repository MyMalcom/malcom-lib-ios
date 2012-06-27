//
//  MPAdView.h
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MPGlobal.h"
#import "MPConstants.h"
#import "MPLogging.h"

typedef enum
{
	MPAdAnimationTypeNone,
	MPAdAnimationTypeRandom,
	MPAdAnimationTypeFlipFromLeft,
	MPAdAnimationTypeFlipFromRight,
	MPAdAnimationTypeCurlUp,
	MPAdAnimationTypeCurlDown,
	MPAdAnimationTypeFade,
	// Important: additional types must be added here to maintain backwards compatibility.
	MPAdAnimationTypeCount
} MPAdAnimationType;

typedef enum
{
	MPNativeAdOrientationAny,
	MPNativeAdOrientationPortrait,
	MPNativeAdOrientationLandscape
} MPNativeAdOrientation;

@protocol MPAdViewDelegate;
@class MPAdManager;

@interface MPAdView : UIView  
{
	// Delegate object for the ad view.
	id<MPAdViewDelegate> _delegate;
	
	// "Business-logic" object for the ad view.
	MPAdManager *_adManager;
	
	// Ad unit identifier for the ad view.
	NSString *_adUnitId;
	
	// Location data which may be used for targeting.
	CLLocation *_location;
		
	// Subview that represents the actual ad content. Set via -setAdContentView.
	UIView *_adContentView;
	
	// Stores the initial size of the ad view.
	CGSize _originalSize;
	
	// Stores the size of the ad creative (handed down from the server). If the server does not
	// pass back size information, this value will be equal to _originalSize.
	CGSize _creativeSize;
	
	// Whether scrolling is enabled for the ad view.
	BOOL _scrollable;
	
	// Whether location data should be sent with MoPub ad requests.
	BOOL _locationEnabled;
	
	// The number of decimal digits to include in location data sent with MoPub ad requests.
	NSUInteger _locationPrecision;
	
	// Pair of strings representing latitude and longitude, taking into account the values of 
	// _locationEnabled and _locationPrecision.
	NSArray *_locationDescriptionPair;
	
	// Specifies the transition used for bringing an ad into view. You can specify an
	// animation type for any ad unit using the MoPub web interface.
	MPAdAnimationType _animationType;
	
	MPNativeAdOrientation _allowedNativeAdOrientation;
	
	// Whether the ad view ignores autorefresh values sent down from the server. If YES,
	// the ad view will never refresh once it has an ad.
	BOOL _ignoresAutorefresh;
}

@property (nonatomic, assign) id<MPAdViewDelegate> delegate;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, copy) CLLocation *location;
@property (nonatomic, retain) NSString *keywords;
@property (nonatomic, assign) CGSize creativeSize;
@property (nonatomic, assign) BOOL scrollable;
@property (nonatomic, assign) BOOL locationEnabled;
@property (nonatomic, assign) NSUInteger locationPrecision;
@property (nonatomic, assign) MPAdAnimationType animationType;
@property (nonatomic, assign) BOOL ignoresAutorefresh;

/*
 * Returns an MPAdView with the given ad unit ID.
 */
- (id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size;

/* 
 * Ad sizes may vary between different ad networks. This method returns the actual
 * size of the underlying ad, which you can use to adjust the size of the MPAdView
 * to avoid clipping or border issues.
 */
- (CGSize)adContentViewSize;

/*
 * Returns an array of two strings representing location coordinates (possibly truncated) as long as
 * a location has been set and locationEnabled is set to YES. If these conditions are not met, this 
 * method will return nil.
 */
- (NSArray *)locationDescriptionPair;

/*
 * Loads a new ad using a default URL constructed from the ad unit ID.
 */
- (void)loadAd;

/*
 * Loads a new ad using the specified URL.
 */
- (void)loadAdWithURL:(NSURL *)URL;

/*
 * Tells the ad view to get another ad using its current URL. Note: if the ad view
 * is already loading an ad, this call does nothing; use -forceRefreshAd instead
 * if you want to cancel any existing ad requests.
 */
- (void)refreshAd;

/*
 * Tells the ad view to get another ad using its current URL, and cancels any existing
 * ad requests.
 */
- (void)forceRefreshAd;

/*
 * Replaces the content of the MPAdView with the specified view and retains the view.
 * 
 * This method is crucial for implementing adapters or custom events involving other 
 * ad networks.
 */
- (void)setAdContentView:(UIView *)view;

/*
 * Signals the internal webview that it has appeared on-screen.
 */
- (void)adViewDidAppear;

/* 
 * Informs the ad view that the device orientation has changed. You should call
 * this method when your application's orientation changes if you want your
 * underlying ads to adjust their orientation properly. You may want to use
 * this method in conjunction with -adContentViewSize, in case the orientation
 * change modifies the size of the underlying ad.
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;

/*
 * Signals the internal webview that it has been closed. This will trigger
 * the -adViewShouldClose delegate callback, if it is implemented.
 */
- (void)didCloseAd:(id)sender;

/*
 * Signals to the ad view that a custom event has caused ad content to load
 * successfully. You must call this method if you implement custom events.
 */
- (void)customEventDidLoadAd;

/*
 * Signals to the ad view that a custom event has resulted in a failed load.
 * You must call this method if you implement custom events.
 */
- (void)customEventDidFailToLoadAd;

/*
 * Signals to the ad view that a user has tapped on a custom-event-triggered ad.
 * You must call this method if you implement custom events, for proper click tracking.
 */
- (void)customEventActionWillBegin;

/*
 * Signals to the ad view that a user has stopped interacting with a custom-event-triggered ad. 
 * You must call this method if you implement custom events.
 */
- (void)customEventActionDidEnd;

/*
 * Forces native ad networks to only use ads sized for the specified orientation. For instance, 
 * if you call this with UIInterfaceOrientationPortrait, native networks (e.g. iAd) will never 
 * return ads sized for the landscape orientation.
 */
- (void)lockNativeAdsToOrientation:(MPNativeAdOrientation)orientation;

/*
 * Allows native ad networks to use ads sized for any orientation. See -lockNativeAdsToOrientation:.
 */
- (void)unlockNativeAdsOrientation;

- (MPNativeAdOrientation)allowedNativeAdsOrientation;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPAdViewDelegate <NSObject>

@required
/*
 * The ad view relies on this method to determine which view controller will be 
 * used for presenting/dismissing modal views, such as the browser view presented 
 * when a user clicks on an ad.
 */
- (UIViewController *)viewControllerForPresentingModalView;

@optional
/*
 * These callbacks notify you regarding whether the ad view (un)successfully
 * loaded an ad.
 */
- (void)adViewDidFailToLoadAd:(MPAdView *)view;
- (void)adViewDidLoadAd:(MPAdView *)view;

/*
 * These callbacks are triggered when the ad view is about to present/dismiss a
 * modal view. If your application may be disrupted by these actions, you can
 * use these notifications to handle them (for example, a game might need to
 * pause/unpause).
 */
- (void)willPresentModalViewForAd:(MPAdView *)view;
- (void)didDismissModalViewForAd:(MPAdView *)view;

/*
 * This callback is triggered when the ad view has retrieved ad parameters
 * (headers) from the MoPub server. See MPInterstitialAdController for an
 * example of how this should be used.
 */
- (void)adView:(MPAdView *)view didReceiveResponseParams:(NSDictionary *)params;

/*
 * This method is called when a mopub://close link is activated. Your implementation of this
 * method should remove the ad view from the screen (see MPInterstitialAdController for an example).
 */
- (void)adViewShouldClose:(MPAdView *)view;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPInterstitialAdView : MPAdView

- (void)forceRedraw;

@end
