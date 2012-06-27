//
//  MPInterstitialAdController.h
//  MoPub
//
//  Created by Andrew He on 2/2/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"
#import "MPBaseInterstitialAdapter.h"

enum
{
	InterstitialCloseButtonStyleAlwaysVisible,
	InterstitialCloseButtonStyleAlwaysHidden,
	InterstitialCloseButtonStyleAdControlled
};
typedef NSUInteger InterstitialCloseButtonStyle;

enum 
{
	InterstitialOrientationTypePortrait,
	InterstitialOrientationTypeLandscape,
	InterstitialOrientationTypeBoth
};
typedef NSUInteger InterstitialOrientationType;

@protocol MPInterstitialAdControllerDelegate;

@interface MPInterstitialAdController : UIViewController <MPAdViewDelegate, MPBaseInterstitialAdapterDelegate>
{
	// Previous state of the status bar, before the interstitial appears.
	BOOL _statusBarWasHidden;
	
	// Previous state of the nav bar, before the interstitial appears.
	BOOL _navigationBarWasHidden;
	
	// Whether the interstitial is fully loaded.
	BOOL _ready;
	
	// Underlying ad view used for the interstitial.
	MPInterstitialAdView *_adView;
	
	// Reference to the view controller that is presenting this interstitial.
	UIViewController<MPInterstitialAdControllerDelegate> *_parent;
	
	// The ad unit ID.
	NSString *_adUnitId;
	
	// Determines how/when the interstitial should display a native close button.
	InterstitialCloseButtonStyle _closeButtonStyle;

	// Whether the ad content has requested that a native close button be shown.
	BOOL _adWantsNativeCloseButton;
	
	// Determines the allowed orientations for the interstitial.
	InterstitialOrientationType _orientationType;
	
	// Button used to dismiss the interstitial.
	UIButton *_closeButton;
	
	MPBaseInterstitialAdapter *_currentAdapter;
    
    // Whether the interstitial is currently being presented.
    BOOL _isOnModalViewControllerStack;
}

@property (nonatomic, readonly, assign) BOOL ready;
@property (nonatomic, assign) UIViewController<MPInterstitialAdControllerDelegate> *parent;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, copy) CLLocation *location;
@property (nonatomic, assign) BOOL locationEnabled;
@property (nonatomic, assign) NSUInteger locationPrecision;
@property (nonatomic, assign) BOOL adWantsNativeCloseButton;

/*
 * A shared pool of interstitial ads.
 */
+ (NSMutableArray *)sharedInterstitialAdControllers;

/*
 * Gets an interstitial for the given ad unit ID. Once created, an interstitial will stay around
 * so that you can retrieve it later.
 */
+ (MPInterstitialAdController *)interstitialAdControllerForAdUnitId:(NSString *)ID;

/*
 * Removes an interstitial from the shared pool.
 */
+ (void)removeSharedInterstitialAdController:(MPInterstitialAdController *)controller;

/*
 * Begin loading the content for the interstitial ad. You may implement the -interstitialDidLoadAd
 * and -interstitialDidFailToLoadAd delegate methods, so that you can decide when to show the ad.
 * This method does not automatically retry if it fails.
 */
- (void)loadAd;

/*
 * Display the interstitial modally.
 */
- (void)show;

/*
 * Returns the result of -locationDescriptionPair on the embedded ad view.
 */
- (NSArray *)locationDescriptionPair;

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

@end

@protocol MPInterstitialAdControllerDelegate <MPAdViewDelegate>
@required
/*
 * This callback notifies you to dismiss the interstitial, and allows you to implement any
 * pre-dismissal behavior (e.g. unpausing a game).
 */
- (void)dismissInterstitial:(MPInterstitialAdController *)interstitial;

/*
 * Interstitial ads from certain networks (e.g. iAd) may expire their content at any time, 
 * regardless of whether the content is currently on-screen. This callback notifies you when the
 * currently-loaded interstitial has expired and is no longer eligible for display. If the ad
 * was on-screen when it expired, you can expect that the ad will already have been dismissed 
 * by the time this callback was fired. Your implementation of this method does not need to include 
 * logic to dismiss an interstitial. It may include a call to -loadAd to fetch a new ad, if desired.
 */
- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial;

@optional
/*
 * These callbacks notify you when the interstitial (un)successfully loads its ad content. You may
 * implement these if you want to prefetch interstitial ads.
 */
- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial;
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial;

/*
 * This callback notifies you that the interstitial is about to appear. This is a good time to
 * handle potential app interruptions (e.g. pause a game).
 */
- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial;
- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial;
- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial;
- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial;
@end

