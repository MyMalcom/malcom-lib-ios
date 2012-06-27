//
//  MPAdManager.h
//  MoPub
//
//  Created by Haydn Dufrene on 6/15/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MPStore.h"
#import "MPBaseAdapter.h"
#import "MPAdBrowserController.h"

extern NSString * const kTimerNotificationName;
extern NSString * const kErrorDomain;
extern NSString * const kMoPubUrlScheme;
extern NSString * const kMoPubCloseHost;
extern NSString * const kMoPubFinishLoadHost;
extern NSString * const kMoPubFailLoadHost;
extern NSString * const kMoPubInAppHost;			
extern NSString * const kMoPubCustomHost;
extern NSString * const kMoPubInterfaceOrientationPortraitId;
extern NSString * const kMoPubInterfaceOrientationLandscapeId;
extern const CGFloat kMoPubRequestTimeoutInterval;
extern const CGFloat kMoPubRequestRetryInterval;
extern NSString * const kClickthroughHeaderKey;
extern NSString * const kLaunchpageHeaderKey;
extern NSString * const kFailUrlHeaderKey;
extern NSString * const kImpressionTrackerHeaderKey;
extern NSString * const kInterceptLinksHeaderKey;
extern NSString * const kScrollableHeaderKey;
extern NSString * const kWidthHeaderKey;			
extern NSString * const kHeightHeaderKey;
extern NSString * const kRefreshTimeHeaderKey;
extern NSString * const kAnimationHeaderKey;
extern NSString * const kAdTypeHeaderKey;
extern NSString * const kNetworkTypeHeaderKey;
extern NSString * const kAdTypeHtml;
extern NSString * const kAdTypeClear;

@class MPAdView, MPTimer, MPTimerTarget, MPBaseAdapter;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000 // iOS 5.0+
@interface MPAdManager : NSObject <MPAdapterDelegate, MPAdBrowserControllerDelegate, 
    UIWebViewDelegate, NSURLConnectionDataDelegate>
#else
@interface MPAdManager : NSObject <MPAdapterDelegate, MPAdBrowserControllerDelegate, 
    UIWebViewDelegate>
#endif
{
	MPAdView *_adView;

	// Ad unit identifier for the ad view.
	NSString *_adUnitId;
	
	// Targeting parameters.
	NSString *_keywords;
	
	// URL for initial MoPub ad request.
	NSURL *_URL;

	// Whether this ad view is currently loading an ad.
	BOOL _isLoading;
	
	// Whether the ad is currently in the middle of a user-triggered action.
	BOOL _adActionInProgress;

    NSMutableURLRequest *_request;
    
	NSURLConnection *_conn;
	
	// Connection data object for ad request.
	NSMutableData *_data;

	// Dictionary of response headers for the current ad request.
	NSDictionary *_headers;
	
	// Pool of webviews being used as HTML ads.
	NSMutableSet *_webviewPool;
		
	// Current adapter being used for serving native ads.
	MPBaseAdapter *_currentAdapter;
	
	// Previous adapter.
	MPBaseAdapter *_previousAdapter;	
	
	// Click-tracking URL.
	NSURL *_clickURL;
	
	// We often need to intercept ad navigation that is not the result of a
	// click. This represents a URL prefix for links we'd like to intercept.
	NSURL *_interceptURL;
	
	// Fall-back URL if an ad request fails.
	NSURL *_failURL;
	
	// Impression-tracking URL.
	NSURL *_impTrackerURL;
	
	// Whether we should intercept any sort of ad navigation.
	BOOL _shouldInterceptLinks;
	
	// Timer that sends a -forceRefreshAd message upon firing, with a time interval handed
	// down from the server. You can set the desired interval for any ad unit using 
	// the MoPub web interface.
	MPTimer *_autorefreshTimer;
	
	// Used as the target object for the MPTimer, in order to avoid a retain cycle (see MPTimer.h).
	MPTimerTarget *_timerTarget;
	
	// Whether the ad view ignores autorefresh values sent down from the server. If YES,
	// the ad view will never refresh once it has a valid ad.
	BOOL _ignoresAutorefresh;
	
	// Whether the autorefresh timer needs to be scheduled. Use case: during a user-triggered ad 
	// action, we must postpone any attempted timer scheduling until the action ends. This flag 
	// allows the "action-ended" callbacks to decide whether the timer needs to be re-scheduled.
	BOOL _autorefreshTimerNeedsScheduling;
    
    BOOL _previousIgnoresAutorefresh;
    
    BOOL _shouldLoadMRAIDAd;
}

@property (nonatomic, readonly) MPAdView *adView;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPInterstitialAdManager : MPAdManager

@end
