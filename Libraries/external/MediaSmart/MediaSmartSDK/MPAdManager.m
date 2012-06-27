//
//  MPAdManager.m
//  MoPub
//
//  Created by Haydn Dufrene on 6/15/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPAdManager.h"
#import "MPAdView.h"
#import "MPAdView+MPAdManagerFriend.h"
#import "MPTimer.h"
#import "MPBaseAdapter.h"
#import "MPAdapterMap.h"
#import "MPConstants.h"
#import "MPGlobal.h"
#import "MPMraidAdapter.h"
#import "MPMraidInterstitialAdapter.h"
#import "CJSONDeserializer.h"

NSString * const kTimerNotificationName = @"Autorefresh";
NSString * const kErrorDomain = @"mopub.com";
NSString * const kMoPubUrlScheme = @"mopub";
NSString * const kMoPubCloseHost = @"close";
NSString * const kMoPubFinishLoadHost = @"finishLoad";
NSString * const kMoPubFailLoadHost = @"failLoad";
NSString * const kMoPubInAppHost = @"inapp";
NSString * const kMoPubCustomHost = @"custom";
NSString * const kMoPubInterfaceOrientationPortraitId = @"p";
NSString * const kMoPubInterfaceOrientationLandscapeId = @"l";
const CGFloat kMoPubRequestTimeoutInterval = 10.0;
const CGFloat kMoPubRequestRetryInterval = 60.0;
NSString * const kClickthroughHeaderKey = @"X-Clickthrough";
NSString * const kLaunchpageHeaderKey = @"X-Launchpage";
NSString * const kFailUrlHeaderKey = @"X-Failurl";
NSString * const kImpressionTrackerHeaderKey = @"X-Imptracker";
NSString * const kInterceptLinksHeaderKey = @"X-Interceptlinks";
NSString * const kScrollableHeaderKey = @"X-Scrollable";
NSString * const kWidthHeaderKey = @"X-Width";
NSString * const kHeightHeaderKey = @"X-Height";
NSString * const kRefreshTimeHeaderKey = @"X-Refreshtime";
NSString * const kAnimationHeaderKey = @"X-Animation";
NSString * const kAdTypeHeaderKey = @"X-Adtype";
NSString * const kNetworkTypeHeaderKey = @"X-Networktype";
NSString * const kAdTypeHtml = @"html";
NSString * const kAdTypeInterstitial = @"interstitial";
NSString * const kAdTypeClear = @"clear";
NSString * const kAdTypeMraid = @"mraid";

@interface MPAdManager ()

@property (nonatomic, assign) MPAdView *adView;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) NSURL *clickURL;
@property (nonatomic, copy) NSURL *interceptURL;
@property (nonatomic, copy) NSURL *failURL;
@property (nonatomic, copy) NSURL *impTrackerURL;
@property (nonatomic, assign) BOOL shouldInterceptLinks;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL ignoresAutorefresh;
@property (nonatomic, assign) BOOL adActionInProgress;
@property (nonatomic, assign) BOOL autorefreshTimerNeedsScheduling;	
@property (nonatomic, retain) MPTimer *autorefreshTimer;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSDictionary *headers;
@property (nonatomic, retain) NSMutableSet *webviewPool;
@property (nonatomic, retain) MPBaseAdapter *currentAdapter;
@property (nonatomic, retain) NSMutableURLRequest *request;

- (void)loadAdWithURL:(NSURL *)URL;
- (void)forceRefreshAd;
- (void)registerForApplicationStateTransitionNotifications;
- (void)removeWebviewFromPool:(UIWebView *)webview;
- (void)destroyWebviewPool;
- (NSString *)orientationQueryStringComponent;
- (NSString *)scaleFactorQueryStringComponent;
- (NSString *)timeZoneQueryStringComponent;
- (NSString *)locationQueryStringComponent;
- (void)replaceCurrentAdapterWithAdapter:(MPBaseAdapter *)newAdapter;
- (void)scheduleAutorefreshTimerIfEnabled;
- (void)scheduleAutorefreshTimer;
- (void)cancelPendingAutorefreshTimer;
- (NSURL *)serverRequestURL;
- (UIWebView *)adWebViewWithFrame:(CGRect)frame;
- (void)trackClick;
- (void)trackImpression;
- (void)setAdContentView:(UIView *)view;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;
- (void)updateOrientationPropertiesForWebView:(UIWebView *)webview;
- (NSDictionary *)dictionaryFromQueryString:(NSString *)query;
- (void)customLinkClickedForSelectorString:(NSString *)selectorString 
							withDataString:(NSString *)dataString;
- (void)processResponseHeaders:(NSDictionary *)headers body:(NSData *)data;
- (void)handleMraidRequest;
- (void)logResponseBodyToConsole:(NSData *)data;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPAdManager

@synthesize adView = _adView;
@synthesize adUnitId = _adUnitId;
@synthesize keywords = _keywords;
@synthesize URL = _URL;
@synthesize clickURL = _clickURL;
@synthesize interceptURL = _interceptURL;
@synthesize failURL = _failURL;
@synthesize impTrackerURL = _impTrackerURL;
@synthesize shouldInterceptLinks = _shouldInterceptLinks;
@synthesize autorefreshTimer = _autorefreshTimer;
@synthesize isLoading = _isLoading;
@synthesize adActionInProgress = _adActionInProgress;
@synthesize ignoresAutorefresh = _ignoresAutorefresh;
@synthesize autorefreshTimerNeedsScheduling = _autorefreshTimerNeedsScheduling;
@synthesize data = _data;
@synthesize headers = _headers;
@synthesize webviewPool = _webviewPool;
@synthesize currentAdapter = _currentAdapter;
@synthesize request = _request;

- (id)init {
	if (self = [super init]) {
		_data = [[NSMutableData data] retain];
		_webviewPool = [[NSMutableSet set] retain];
		_shouldInterceptLinks = YES;
		_timerTarget = [[MPTimerTarget alloc] initWithNotificationName:kTimerNotificationName];
        _request = [[NSMutableURLRequest alloc] initWithURL:nil
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                 timeoutInterval:kMoPubRequestTimeoutInterval];
        [_request setValue:MPUserAgentString() forHTTPHeaderField:@"User-Agent"];			
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(forceRefreshAd)
													 name:kTimerNotificationName
												   object:_timerTarget];		
		[self registerForApplicationStateTransitionNotifications];
	}
	return self;
}

- (void)setAdView:(MPAdView *)adView {
    _adView = adView;
    
    self.adUnitId = adView.adUnitId;
    self.ignoresAutorefresh = adView.ignoresAutorefresh;
}

- (void)registerForApplicationStateTransitionNotifications
{
	// iOS version > 4.0: Register for relevant application state transition notifications.
	if (&UIApplicationDidEnterBackgroundNotification != nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationDidEnterBackground) 
													 name:UIApplicationDidEnterBackgroundNotification 
												   object:[UIApplication sharedApplication]];
	}		
	if (&UIApplicationWillEnterForegroundNotification != nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationWillEnterForeground)
													 name:UIApplicationWillEnterForegroundNotification 
												   object:[UIApplication sharedApplication]];
	}
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];	
		
	[self destroyWebviewPool];
	
	[_currentAdapter unregisterDelegate];
	[_currentAdapter release];
	[_previousAdapter unregisterDelegate];
	[_previousAdapter release];
	[_adUnitId release];
	[_conn cancel];
	[_conn release];
	[_data release];
	[_headers release];
	[_URL release];
	[_clickURL release];
	[_interceptURL release];
	[_failURL release];
	[_impTrackerURL release];
	[_keywords release];
	[_autorefreshTimer invalidate];
	[_autorefreshTimer release];
	[_timerTarget release];
    [_request release];
	
	_adView = nil;
    [super dealloc];
}

- (void)removeWebviewFromPool:(UIWebView *)webview
{
	[_webviewPool removeObject:webview];
}

- (void)destroyWebviewPool
{
	for (UIWebView *webview in _webviewPool)
	{
		[webview setDelegate:nil];
		[webview stopLoading];
	}
	[_webviewPool release];
}

- (void)refreshAd
{
	[self cancelPendingAutorefreshTimer];
	[self loadAdWithURL:nil];
}

- (void)forceRefreshAd
{
	// Cancel any existing request to the ad server.
	[_conn cancel];
	
	_isLoading = NO;
	[self cancelPendingAutorefreshTimer];
	[self loadAdWithURL:nil];
}

- (void)loadAdWithURL:(NSURL *)URL
{
	if (_isLoading) 
	{
		MPLogWarn(@"Ad view (%p) already loading an ad. Wait for previous load to finish.", self.adView);
		return;
	}
	
	self.URL = (URL) ? URL : [self serverRequestURL];
	MPLogDebug(@"Ad view (%p) loading ad with MoPub server URL: %@", self.adView, self.URL);
	
    _request.URL = self.URL;
	[_conn release];
	_conn = [[NSURLConnection connectionWithRequest:_request delegate:self] retain];
	_isLoading = YES;
	
	MPLogInfo(@"Ad manager (%p) fired initial ad request.", self);
}

- (NSURL *)serverRequestURL {
	NSString *urlString = [NSString stringWithFormat:@"http://%@/m/ad?v=8&udid=%@&q=%@&id=%@&nv=%@", 
						   HOSTNAME,
						   MPHashedUDID(),
						   [_keywords stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						   [_adUnitId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						   MP_SDK_VERSION];
	
	urlString = [urlString stringByAppendingString:[self orientationQueryStringComponent]];
	urlString = [urlString stringByAppendingString:[self scaleFactorQueryStringComponent]];
	urlString = [urlString stringByAppendingString:[self timeZoneQueryStringComponent]];
	urlString = [urlString stringByAppendingString:[self locationQueryStringComponent]];
    
    if (NSClassFromString(@"MPMraidAdapter") != nil) {
        urlString = [urlString stringByAppendingString:@"&mr=1"];
    }
    
	return [NSURL URLWithString:urlString];
}

- (NSString *)orientationQueryStringComponent
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	NSString *orientString = UIInterfaceOrientationIsPortrait(orientation) ?
		kMoPubInterfaceOrientationPortraitId : kMoPubInterfaceOrientationLandscapeId;
	return [NSString stringWithFormat:@"&o=%@", orientString];
}

- (NSString *)scaleFactorQueryStringComponent
{
	return [NSString stringWithFormat:@"&sc=%.1f", MPDeviceScaleFactor()];
}

- (NSString *)timeZoneQueryStringComponent
{
	static NSDateFormatter *formatter;
	@synchronized(self)
	{
		if (!formatter) formatter = [[NSDateFormatter alloc] init];
	}
	[formatter setDateFormat:@"Z"];
	NSDate *today = [NSDate date];
	return [NSString stringWithFormat:@"&z=%@", [formatter stringFromDate:today]];
}

- (NSString *)locationQueryStringComponent
{
	NSString *result = @"";
	
	NSArray *locationPair = [self.adView locationDescriptionPair];
	if ([locationPair count] == 2) {
		result = [result stringByAppendingFormat:
				  @"&ll=%@,%@",
				  [locationPair objectAtIndex:0],
				  [locationPair objectAtIndex:1]];
	}
	
	return result;
}

- (NSDictionary *)dictionaryFromQueryString:(NSString *)query
{
	NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] initWithCapacity:1];
	NSArray *queryElements = [query componentsSeparatedByString:@"&"];
	for (NSString *element in queryElements) {
		NSArray *keyVal = [element componentsSeparatedByString:@"="];
		NSString *key = [keyVal objectAtIndex:0];
		NSString *value = [keyVal lastObject];
		[queryDict setObject:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
					  forKey:key];
	}
	return [queryDict autorelease];
}

- (void)trackClick
{
    [_request setURL:self.clickURL];
	[NSURLConnection connectionWithRequest:_request delegate:nil];
	MPLogDebug(@"Ad view (%p) tracking click %@", self, self.clickURL);
}

- (void)trackImpression
{
    [_request setURL:self.impTrackerURL];
	[NSURLConnection connectionWithRequest:_request delegate:nil];
	MPLogDebug(@"Ad view (%p) tracking impression %@", self, self.impTrackerURL);
}

- (void)setAdContentView:(UIView *)view
{
	[self.adView setAdContentView:view];
}

- (void)setIgnoresAutorefresh:(BOOL)ignoresAutorefresh
{
    _ignoresAutorefresh = ignoresAutorefresh;
    if (_ignoresAutorefresh) {
        MPLogDebug(@"Ad view (%p) is now ignoring autorefresh.", self);
        if ([self.autorefreshTimer isScheduled]) [self.autorefreshTimer pause];
    } else {
        MPLogDebug(@"Ad view (%p) is no longer ignoring autorefresh.", self);
        if ([self.autorefreshTimer isScheduled]) [self.autorefreshTimer resume];
    }
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
	if (self.currentAdapter) {
		[self.currentAdapter rotateToOrientation:orientation];
	} else if ([self.adView.adContentView isKindOfClass:[UIWebView class]]) {
		[self updateOrientationPropertiesForWebView:(UIWebView *)self.adView.adContentView];
	}
}

- (void)updateOrientationPropertiesForWebView:(UIWebView *)webview
{
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	int angle = -1;
	switch (orientation)
	{
		case UIDeviceOrientationPortrait: angle = 0; break;
		case UIDeviceOrientationLandscapeLeft: angle = 90; break;
		case UIDeviceOrientationLandscapeRight: angle = -90; break;
		case UIDeviceOrientationPortraitUpsideDown: angle = 180; break;
		default: break;
	}
	
	if (angle == -1) return;
	
	// UIWebView doesn't seem to fire the 'orientationchange' event upon rotation, so we do it here.
	NSString *orientationEventScript = [NSString stringWithFormat:
					@"window.__defineGetter__('orientation',function(){return %d;});"
					@"(function(){ var evt = document.createEvent('Events');"
					@"evt.initEvent('orientationchange',true,true);window.dispatchEvent(evt);})();",
					angle];
	[webview stringByEvaluatingJavaScriptFromString:orientationEventScript];
	
	// XXX: If the UIWebView is rotated off-screen (which may happen with interstitials), its 
	// content may render off-center upon display. We compensate by setting the viewport meta tag's 
	// 'width' attribute to be the size of the webview.
	NSString *viewportUpdateScript = [NSString stringWithFormat:
					  @"document.querySelector('meta[name=viewport]')"
                      @".setAttribute('content', 'width=%f;', false);",
					  webview.frame.size.width];
	[webview stringByEvaluatingJavaScriptFromString:viewportUpdateScript];
}

- (void)customEventDidLoadAd
{
	_isLoading = NO;
  [self scheduleAutorefreshTimerIfEnabled];
	[self trackImpression];
}

- (void)customEventDidFailToLoadAd 
{
	_isLoading = NO;
	[self loadAdWithURL:self.failURL];
}

- (void)customEventActionWillBegin 
{
    [self userActionWillBeginForAdapter:self.currentAdapter];
}

- (void)customEventActionDidEnd
{
    [self userActionDidFinishForAdapter:self.currentAdapter];
}

- (UIViewController *)viewControllerForPresentingModalView 
{
	return [self.adView.delegate viewControllerForPresentingModalView];
}

- (void)customLinkClickedForSelectorString:(NSString *)selectorString 
							withDataString:(NSString *)dataString
{
	if (!selectorString)
	{
		MPLogError(@"Custom selector requested, but no custom selector string was provided.",
				   selectorString);
	}
	
	SEL selector = NSSelectorFromString(selectorString);
	
	// First, try calling the no-object selector.
	if ([self.adView.delegate respondsToSelector:selector])
	{
		[self.adView.delegate performSelector:selector];
	}
	// Then, try calling the selector passing in the ad view.
	else 
	{
		NSString *selectorWithObjectString = [NSString stringWithFormat:@"%@:", selectorString];
		SEL selectorWithObject = NSSelectorFromString(selectorWithObjectString);
		
		if ([self.adView.delegate respondsToSelector:selectorWithObject])
		{
            CJSONDeserializer *deserializer = [CJSONDeserializer deserializerWithNullObject:NULL];
			NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
			NSDictionary *dataDictionary = [deserializer deserializeAsDictionary:data error:NULL];
			[self.adView.delegate performSelector:selectorWithObject withObject:dataDictionary];
		}
		else
		{
			MPLogError(@"Ad view delegate does not implement custom selectors %@ or %@.",
					   selectorString,
					   selectorWithObjectString);
		}
	}
}

- (void)adLinkClicked:(NSURL *)URL
{
	_adActionInProgress = YES;
	
	// Construct the URL that we want to load in the ad browser, using the click-tracking URL.
	NSString *redirectURLString = [[URL absoluteString] URLEncodedString];	
	NSURL *desiredURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@&r=%@",
											  _clickURL,
											  redirectURLString]];
	
	// Notify delegate that the ad browser is about to open.
	if ([self.adView.delegate respondsToSelector:@selector(willPresentModalViewForAd:)])
		[self.adView.delegate willPresentModalViewForAd:self.adView];
	
	if ([self.autorefreshTimer isScheduled])
		[self.autorefreshTimer pause];
	
	// Present ad browser.
	MPAdBrowserController *browserController = [[MPAdBrowserController alloc] initWithURL:desiredURL 
																				 delegate:self];
	[[self viewControllerForPresentingModalView] presentModalViewController:browserController 			
																   animated:YES];
	[browserController release];
}

- (void)replaceCurrentAdapterWithAdapter:(MPBaseAdapter *)newAdapter
{
	// Dispose of the last adapter stored in _previousAdapter.
	[_previousAdapter unregisterDelegate];
  [_previousAdapter release];
	
	_previousAdapter = _currentAdapter;
	_currentAdapter = newAdapter;
  [_currentAdapter retain];
}

#pragma mark -
#pragma mark MPAdBrowserControllerDelegate

- (void)dismissBrowserController:(MPAdBrowserController *)browserController {
	[self dismissBrowserController:browserController animated:YES];
}

- (void)dismissBrowserController:(MPAdBrowserController *)browserController animated:(BOOL)animated
{
	_adActionInProgress = NO;
	[[self viewControllerForPresentingModalView] dismissModalViewControllerAnimated:animated];
	
	if ([self.adView.delegate respondsToSelector:@selector(didDismissModalViewForAd:)])
		[self.adView.delegate didDismissModalViewForAd:self.adView];
	
	if (_autorefreshTimerNeedsScheduling)
	{
		[self.autorefreshTimer scheduleNow];
		_autorefreshTimerNeedsScheduling = NO;
	}
	else if ([self.autorefreshTimer isScheduled]) [self.autorefreshTimer resume];
}

# pragma mark -
# pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	if ([response respondsToSelector:@selector(statusCode)])
	{
		int statusCode = [((NSHTTPURLResponse *)response) statusCode];
		if (statusCode >= 400)
		{
			[connection cancel];
			NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
																		  NSLocalizedString(@"Server returned status code %d", @""),
																		  statusCode]
																  forKey:NSLocalizedDescriptionKey];
			NSError *statusError = [NSError errorWithDomain:@"mopub.com"
													   code:statusCode
												   userInfo:errorInfo];
			[self connection:connection didFailWithError:statusError];
			return;
		}
	}
	
	MPLogInfo(@"Ad view (%p) received valid response from MoPub server.", self);
	
	// Initialize data.
	[_data release];
	_data = [[NSMutableData data] retain];
	
	// Parse response headers, set relevant URLs and booleans.
	NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
	NSString *urlString = nil;
	
	urlString = [headers objectForKey:kClickthroughHeaderKey];
	self.clickURL = urlString ? [NSURL URLWithString:urlString] : nil;
	
	urlString = [headers objectForKey:kLaunchpageHeaderKey];
	self.interceptURL = urlString ? [NSURL URLWithString:urlString] : nil;
	
	urlString = [headers objectForKey:kFailUrlHeaderKey];
	self.failURL = urlString ? [NSURL URLWithString:urlString] : nil;
	
	urlString = [headers objectForKey:kImpressionTrackerHeaderKey];
	self.impTrackerURL = urlString ? [NSURL URLWithString:urlString] : nil;
	
	NSString *shouldInterceptLinksString = [headers objectForKey:kInterceptLinksHeaderKey];
	if (shouldInterceptLinksString)
		self.shouldInterceptLinks = [shouldInterceptLinksString boolValue];
	
	NSString *scrollableString = [headers objectForKey:kScrollableHeaderKey];
	if (scrollableString)
		self.adView.scrollable = [scrollableString boolValue];
	
	NSString *widthString = [headers objectForKey:kWidthHeaderKey];
	NSString *heightString = [headers objectForKey:kHeightHeaderKey];
	
	// Try to get the creative size from the server or otherwise use the original container's size.
	if (widthString && heightString)
		self.adView.creativeSize = CGSizeMake([widthString floatValue], [heightString floatValue]);
	else
		self.adView.creativeSize = self.adView.originalSize;
	
	// Create the autorefresh timer, which will be scheduled either when the ad appears,
	// or if it fails to load.
	NSString *refreshString = [headers objectForKey:kRefreshTimeHeaderKey];
	if (refreshString)
	{
		NSTimeInterval interval = [refreshString doubleValue];
		interval = (interval >= MINIMUM_REFRESH_INTERVAL) ? interval : MINIMUM_REFRESH_INTERVAL;
		self.autorefreshTimer = [MPTimer timerWithTimeInterval:interval
													  target:_timerTarget 
													  selector:@selector(postNotification) 
													  userInfo:nil 
													  repeats:NO];
	}
	
	NSString *animationString = [headers objectForKey:kAnimationHeaderKey];
	if (animationString)
		self.adView.animationType = [animationString intValue];
	
	// Log if the ad is from an ad network
	NSString *networkTypeHeader = [[(NSHTTPURLResponse *)response allHeaderFields] 
								   objectForKey:kNetworkTypeHeaderKey];
	if (networkTypeHeader && ![networkTypeHeader isEqualToString:@""])
	{
		MPLogInfo(@"Fetching Ad Network Type: %@", networkTypeHeader);
	}

	self.headers = headers;
	
	// Determine ad type.
	NSString *typeHeader = [headers	objectForKey:kAdTypeHeaderKey];
	
	if (!typeHeader || [typeHeader isEqualToString:kAdTypeClear]) {
		[self replaceCurrentAdapterWithAdapter:nil];
		
		// Show a blank.
		MPLogInfo(@"No ad available");
		[connection cancel];
		_isLoading = NO;
		[self.adView backFillWithNothing];
		[self scheduleAutorefreshTimerIfEnabled];
		return;
	} else if ([typeHeader isEqualToString:kAdTypeHtml] || 
			[typeHeader isEqualToString:kAdTypeInterstitial]) {
		// HTML ad, so just return. connectionDidFinishLoading: will take care of the rest.
		[self replaceCurrentAdapterWithAdapter:nil];
		return;
	} else if ([typeHeader isEqualToString:kAdTypeMraid]) {
		[self replaceCurrentAdapterWithAdapter:nil];
        _shouldLoadMRAIDAd = YES;
        return;
    }
	
	// Obtain adapter for specified ad type.
	NSString *classString = [[MPAdapterMap sharedAdapterMap] classStringForAdapterType:typeHeader];
	Class cls = NSClassFromString(classString);
	if (cls != nil)
	{
		MPBaseAdapter *newAdapter = [(MPBaseAdapter *)[[cls alloc] initWithAdapterDelegate:self] autorelease];
		[self replaceCurrentAdapterWithAdapter:newAdapter];
		
		[connection cancel];
		
		// Tell adapter to fire off ad request.
		NSDictionary *params = [(NSHTTPURLResponse *)response allHeaderFields];
		[_currentAdapter _getAdWithParams:params];
	}
	// Else: no adapter for the specified ad type, so just fail over.
	else 
	{
		[self replaceCurrentAdapterWithAdapter:nil];
		
		[connection cancel];
		_isLoading = NO;
		
		[self loadAdWithURL:self.failURL];
	}	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
	[_data appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	MPLogError(@"Ad view (%p) failed to get a valid response from MoPub server. Error: %@", 
			   self, error);
	
	// If the initial request to MoPub fails, replace the current ad content with a blank.
	_isLoading = NO;
	[self.adView backFillWithNothing];
	
	// Create an autorefresh timer if there isn't a valid one.
	if (!self.autorefreshTimer || ![self.autorefreshTimer isValid])
	{
		self.autorefreshTimer = [MPTimer timerWithTimeInterval:kMoPubRequestRetryInterval 
														target:_timerTarget 
													  selector:@selector(postNotification) 
													  userInfo:nil 
													   repeats:NO];
	}
	
	// If the MoPub server returns an error, we should retry even if _ignoresAutorefresh is set to 
	// YES. This avoids the case where the ad view stays blank if its first request happens to fail.
	[self scheduleAutorefreshTimer];	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.headers];
    [params setObject:_data forKey:@"payload"];
    
	if ([self.adView.delegate respondsToSelector:@selector(adView:didReceiveResponseParams:)])
		[self.adView.delegate adView:self.adView didReceiveResponseParams:params];
	
	[self processResponseHeaders:self.headers body:_data];
	[self logResponseBodyToConsole:_data];
}

- (void)processResponseHeaders:(NSDictionary *)headers body:(NSData *)data
{
	if (_shouldLoadMRAIDAd) {
	    [self handleMraidRequest];
    	_shouldLoadMRAIDAd = NO;
	    return;
    } else {
    	// Generate a new webview to contain the HTML and add it to the webview pool.
		UIWebView *webview = [self adWebViewWithFrame:(CGRect){{0, 0}, self.adView.creativeSize}];
		webview.delegate = self;
		[_webviewPool addObject:webview];
		[webview loadData:_data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:self.URL];
    }
}

- (void)handleMraidRequest
{
	MPMraidAdapter *adapter = [[[MPMraidAdapter alloc] initWithAdapterDelegate:self] autorelease];
	[self replaceCurrentAdapterWithAdapter:adapter];

	CGSize size = self.adView.creativeSize;
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%f", size.width], @"adWidth",
                        [NSString stringWithFormat:@"%f", size.height], @"adHeight",
                        _data, @"payload",
                        nil];
	[adapter getAdWithParams:params];
}

- (void)logResponseBodyToConsole:(NSData *)data
{
	if (MPLogGetLevel() <= MPLogLevelTrace)
	{
		NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		MPLogTrace(@"Ad view (%p) loaded HTML content: %@", self, response);
		[response release];
	}
}

- (void)scheduleAutorefreshTimerIfEnabled
{
	if (_ignoresAutorefresh) return;
	else [self scheduleAutorefreshTimer];
}

- (void)scheduleAutorefreshTimer 
{
	if (_adActionInProgress)
	{
		MPLogDebug(@"Ad action in progress: MPTimer will be scheduled after action ends.");
		_autorefreshTimerNeedsScheduling = YES;
	}
	else if ([self.autorefreshTimer isScheduled])
	{
		MPLogDebug(@"Tried to schedule the autorefresh timer, but it was already scheduled.");
	}
	else if (self.autorefreshTimer == nil)
	{
		MPLogDebug(@"Tried to schedule the autorefresh timer, but it was nil.");
	}
	else
	{
		[self.autorefreshTimer scheduleNow];
	}
}

- (void)cancelPendingAutorefreshTimer {
	[self.autorefreshTimer invalidate];
}

#pragma mark -
#pragma mark MPAdapterDelegate

- (void)adapter:(MPBaseAdapter *)adapter didFinishLoadingAd:(UIView *)ad
		shouldTrackImpression:(BOOL)shouldTrack
{
	_isLoading = NO;
	[self.adView setAdContentView:ad];
	
	if (shouldTrack) [self trackImpression];
	[self scheduleAutorefreshTimerIfEnabled];
	
	if ([self.adView.delegate respondsToSelector:@selector(adViewDidLoadAd:)])
		[self.adView.delegate adViewDidLoadAd:self.adView];	
}

- (void)adapter:(MPBaseAdapter *)adapter didFailToLoadAdWithError:(NSError *)error
{
	// Ignore fail messages from the previous adapter.
	if (_previousAdapter && adapter == _previousAdapter) return;
	
	_isLoading = NO;
	MPLogError(@"Adapter (%p) failed to load ad. Error: %@", adapter, error);
	
	// Dispose of the current adapter, because we don't want it to try loading again.
	[_currentAdapter unregisterDelegate];
    
    if (_currentAdapter.class == NSClassFromString(@"MPMillennialAdapter")) {
        // XXX: Millennial says an MMAdView must not be deallocated immediately after it fails
        // to load an ad, because it will result in a crash. This means that we can't immediately 
        // release our Millennial adapters. Their suggestion was to use this ugly delay.
        [_currentAdapter performSelector:@selector(release) withObject:nil afterDelay:1];
    } else {
        [_currentAdapter release];
    }
    
	_currentAdapter = nil;
	
	// An adapter will sometimes send this message during a user action (example: user taps on an 
	// iAd; iAd then does an internal refresh and fails). In this case, we schedule a new request
	// to occur after the action ends. Otherwise, just start a new request using the fall-back URL.
	if (_adActionInProgress) [self scheduleAutorefreshTimerIfEnabled];
	else [self loadAdWithURL:self.failURL];
	
}

- (void)userActionWillBeginForAdapter:(MPBaseAdapter *)adapter
{
	_adActionInProgress = YES;
	[self trackClick];
	
	if ([self.autorefreshTimer isScheduled])
		[self.autorefreshTimer pause];
	
	// Notify delegate that the ad will present a modal view / disrupt the app.
	if ([self.adView.delegate respondsToSelector:@selector(willPresentModalViewForAd:)])
		[self.adView.delegate willPresentModalViewForAd:self.adView];	
}

- (void)userActionDidFinishForAdapter:(MPBaseAdapter *)adapter
{
	_adActionInProgress = NO;
	
	if (_autorefreshTimerNeedsScheduling)
	{
		[self.autorefreshTimer scheduleNow];
		_autorefreshTimerNeedsScheduling = NO;
	}
	else if ([self.autorefreshTimer isScheduled]) [self.autorefreshTimer resume];
	
	// Notify delegate that the ad's modal view was dismissed, returning focus to the app.
	if ([self.adView.delegate respondsToSelector:@selector(didDismissModalViewForAd:)])
		[self.adView.delegate didDismissModalViewForAd:self.adView];	
}

- (void)userWillLeaveApplicationFromAdapter:(MPBaseAdapter *)adapter
{
	// TODO: Implement.
}

- (CGSize)maximumAdSize
{
	return [self.adView adContentViewSize];
}

- (MPNativeAdOrientation)allowedNativeAdsOrientation
{
	return [self.adView allowedNativeAdsOrientation];
}

- (void)pauseAutorefresh
{
    _previousIgnoresAutorefresh = _ignoresAutorefresh;
    [self setIgnoresAutorefresh:YES];
}

- (void)resumeAutorefreshIfEnabled
{
    [self setIgnoresAutorefresh:_previousIgnoresAutorefresh];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *URL = [request URL];
	
	// Handle the custom mopub:// scheme.
	if ([[URL scheme] isEqualToString:kMoPubUrlScheme])
	{
		NSString *host = [URL host];
		if ([host isEqualToString:kMoPubCloseHost])
		{
			[self.adView didCloseAd:nil];
		}
		else if ([host isEqualToString:kMoPubFinishLoadHost])
		{
			_isLoading = NO;
			
			[self.adView setAdContentView:webView];
			[self scheduleAutorefreshTimerIfEnabled];
			
			// Notify delegate that an ad has been loaded.
			if ([self.adView.delegate respondsToSelector:@selector(adViewDidLoadAd:)]) 
				[self.adView.delegate adViewDidLoadAd:self.adView];
		}
		else if ([host isEqualToString:kMoPubFailLoadHost])
		{
			_isLoading = NO;
			
			// Deallocate this webview by removing it from the pool.
			webView.delegate = nil;
			[webView stopLoading];
			[_webviewPool removeObject:webView];
			
			// Start a new request using the fall-back URL.
			[self loadAdWithURL:self.failURL];
		}
	    else if ([host isEqualToString:kMoPubInAppHost])
		{
			[self trackClick];
			NSDictionary *queryDict = [self dictionaryFromQueryString:[URL query]];
			[[MPStore sharedStore] initiatePurchaseForProductIdentifier:[queryDict objectForKey:@"id"] 
												quantity:[[queryDict objectForKey:@"num"] intValue]];
		}
	    else if ([host isEqualToString:kMoPubCustomHost])
		{
			[self trackClick];
			NSDictionary *queryDict = [self dictionaryFromQueryString:[URL query]];
			[self customLinkClickedForSelectorString:[queryDict objectForKey:@"fnc"]
									  withDataString:[queryDict objectForKey:@"data"]];
		}
		
		return NO;
	}
	
	// Intercept non-click forms of navigation (e.g. "window.location = ...") if the target URL
	// has the interceptURL prefix. Launch the ad browser.
	if (navigationType == UIWebViewNavigationTypeOther && 
		self.shouldInterceptLinks && 
		self.interceptURL &&
		[[URL absoluteString] hasPrefix:[self.interceptURL absoluteString]])
	{
		[self adLinkClicked:URL];
		return NO;
	}
	
	// Launch the ad browser for all clicks (if shouldInterceptLinks is YES).
	if (navigationType == UIWebViewNavigationTypeLinkClicked && self.shouldInterceptLinks)
	{
		[self adLinkClicked:URL];
		return NO;
	}
	
	// Other stuff (e.g. JavaScript) should load as usual.
	return YES;	
}

- (UIWebView *)adWebViewWithFrame:(CGRect)frame
{
	UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
	webView.backgroundColor = [UIColor clearColor];
	webView.opaque = NO;
	return [webView autorelease];
}

# pragma mark -
# pragma mark UIApplicationNotification responders

- (void)applicationDidEnterBackground
{
	[self.autorefreshTimer pause];
}

- (void)applicationWillEnterForeground
{
	_autorefreshTimerNeedsScheduling = NO;
	if (!_ignoresAutorefresh) {
        [self forceRefreshAd];
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPInterstitialAdManager

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	MPLogError(@"Ad view (%p) failed to get a valid response from MoPub server. Error: %@", 
			   self, error);
	
	// If the initial request to MoPub fails, replace the current ad content with a blank.
	_isLoading = NO;
	[self.adView backFillWithNothing];
}

- (void)handleMraidRequest
{
	// The loading of an MRAID interstitial ad is done through -adView:didReceiveResponseParams:, so
	// we don't need to do anything here.
}

- (UIWebView *)adWebViewWithFrame:(CGRect)frame
{
	UIWebView *webView = [super adWebViewWithFrame:frame];
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	return webView;
}

@end
