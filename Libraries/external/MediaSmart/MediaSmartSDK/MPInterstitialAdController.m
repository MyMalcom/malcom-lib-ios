//
//  MPInterstitialAdController.m
//  MoPub
//
//  Created by Andrew He on 2/2/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialAdController.h"
#import "MPBaseInterstitialAdapter.h"
#import "MPAdapterMap.h"
#import "MPAdView+MPInterstitialAdControllerFriend.h"
#import "MPAdManager+MPInterstitialAdControllerFriend.h"

static const CGFloat kCloseButtonPadding				= 6.0;
static NSString * const kCloseButtonXImageName			= @"MPCloseButtonX.png";

// Ad header key/value constants.
static NSString * const kCloseButtonHeaderKey			= @"X-Closebutton";
static NSString * const kCloseButtonNone				= @"None";
static NSString * const kOrientationHeaderKey			= @"X-Orientation";
static NSString * const kOrientationPortraitOnly		= @"p";
static NSString * const kOrientationLandscapeOnly		= @"l";
static NSString * const kOrientationBoth				= @"b";

@interface MPInterstitialAdController ()

@property (nonatomic, assign) InterstitialCloseButtonStyle closeButtonStyle;
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, retain) MPBaseInterstitialAdapter *currentAdapter;

- (id)initWithAdUnitId:(NSString *)ID parentViewController:(UIViewController *)parent;
- (void)setCloseButtonImageNamed:(NSString *)name;
- (void)layoutCloseButton;
- (void)closeButtonPressed;
- (void)presentInterstitialModalViewController;

@end

@implementation MPInterstitialAdController

@synthesize ready = _ready;
@synthesize parent = _parent;
@synthesize adUnitId = _adUnitId;
@synthesize closeButtonStyle = _closeButtonStyle;
@synthesize adWantsNativeCloseButton = _adWantsNativeCloseButton;
@synthesize closeButton = _closeButton;
@synthesize currentAdapter = _currentAdapter;
@synthesize keywords;
@synthesize location;
@synthesize locationEnabled;
@synthesize locationPrecision;

#pragma mark -
#pragma mark Class methods

+ (NSMutableArray *)sharedInterstitialAdControllers
{
	static NSMutableArray *sharedInterstitialAdControllers;
	
	@synchronized(self)
	{
		if (!sharedInterstitialAdControllers)
			sharedInterstitialAdControllers = [[NSMutableArray alloc] initWithCapacity:1];
	}
	return sharedInterstitialAdControllers;
}

+ (MPInterstitialAdController *)interstitialAdControllerForAdUnitId:(NSString *)ID
{	
	NSMutableArray *controllers = [MPInterstitialAdController sharedInterstitialAdControllers];
	
	@synchronized(self)
	{
		// Find the correct ad controller based on the ad unit ID.
		MPInterstitialAdController *controller = nil;
		for (MPInterstitialAdController *c in controllers)
		{
			if ([c.adUnitId isEqualToString:ID])
			{
				controller = c;
				break;
			}
		}
		
		// Create the ad controller if it doesn't exist.
		if (!controller)
		{
			controller = [[[MPInterstitialAdController alloc] initWithAdUnitId:ID 
														  parentViewController:nil] autorelease];
			[controllers addObject:controller];
		}
		return controller;
	}
}

+ (void)removeSharedInterstitialAdController:(MPInterstitialAdController *)controller
{
	NSMutableArray *sharedInterstitialAdControllers = 
		[MPInterstitialAdController sharedInterstitialAdControllers];
	[sharedInterstitialAdControllers removeObject:controller];
}

+ (void)removeAllSharedInterstitialAdControllers
{
	NSMutableArray *sharedInterstitialAdControllers = 
		[MPInterstitialAdController sharedInterstitialAdControllers];
	[sharedInterstitialAdControllers removeAllObjects];
}

#pragma mark -
#pragma mark Lifecycle

- (id)initWithAdUnitId:(NSString *)ID 
  parentViewController:(UIViewController<MPInterstitialAdControllerDelegate> *)parent
{
	if (self = [super init])
	{
		_parent = parent;
		_adUnitId = [ID copy];
		_closeButtonStyle = InterstitialCloseButtonStyleAdControlled;
		_adWantsNativeCloseButton = YES;
		_orientationType = InterstitialOrientationTypeBoth;
		
		CGRect bounds = [UIScreen mainScreen].bounds;
		_adView = [[MPInterstitialAdView alloc] initWithAdUnitId:self.adUnitId size:bounds.size];
		_adView.ignoresAutorefresh = YES;
		_adView.delegate = self;
        _adView.alpha = 0.0;
		
		// Typically, we don't set an autoresizing mask for MPAdView, but in this case we always
		// want it to occupy the full screen.
		_adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
			UIViewAutoresizingFlexibleHeight;
	}
	return self;
}

- (void)dealloc 
{
	_parent = nil;
	_adView.delegate = nil;
	[_currentAdapter unregisterDelegate];
	[_currentAdapter release];
	[_adView release];
	[_adUnitId release];
    [_closeButton release];
    [super dealloc];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_adView];
    [self layoutCloseButton];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	if (!_isOnModalViewControllerStack) {
        _isOnModalViewControllerStack = YES;
        [_adView adViewDidAppear];
        
        // XXX: In certain cases, UIWebView's content appears off-center due to rotation / auto-
        // resizing while off-screen. -forceRedraw corrects this issue, but there is always a brief
        // instant when the old content is visible. We mask this using a short fade animation.
        [_adView forceRedraw];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        _adView.alpha = 1.0;
        [UIView commitAnimations];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    // -viewDidDisappear: is called 1) when the interstitial is dismissed and 2) when a modal view
	// controller is presented (e.g. the ad browser). We only want to send a "did disappear" message
    // to the delegate for the first case -- when the interstitial has actually been dismissed.
	if (!self.modalViewController) {
        _isOnModalViewControllerStack = NO;
        _adView.alpha = 0.0;
        [self interstitialDidDisappearForAdapter:nil];
    }
}

#pragma mark -
#pragma mark Internal

- (void)setCloseButtonStyle:(InterstitialCloseButtonStyle)closeButtonStyle
{
    _closeButtonStyle = closeButtonStyle;
    [self layoutCloseButton];
}

- (void)setAdWantsNativeCloseButton:(BOOL)adWantsNativeCloseButton
{
    _adWantsNativeCloseButton = adWantsNativeCloseButton;
    [self layoutCloseButton];
}

- (void)setCloseButtonImageNamed:(NSString *)name
{
	UIImage *image = [UIImage imageNamed:name];
	[self.closeButton setImage:image forState:UIControlStateNormal];
	[self.closeButton sizeToFit];
}

- (void)layoutCloseButton
{
	if (!self.closeButton) 
	{
		self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | 
			UIViewAutoresizingFlexibleBottomMargin;
		[self.closeButton addTarget:self 
							 action:@selector(closeButtonPressed) 
				   forControlEvents:UIControlEventTouchUpInside];
		[self setCloseButtonImageNamed:kCloseButtonXImageName];
		
		CGFloat originx = self.view.bounds.size.width;
		originx -= self.closeButton.bounds.size.width + kCloseButtonPadding;
		self.closeButton.frame = CGRectMake(originx, 
											kCloseButtonPadding, 
											self.closeButton.bounds.size.width,
											self.closeButton.bounds.size.height);
		
		[self.view addSubview:self.closeButton];
	}

	switch (_closeButtonStyle) {
		case InterstitialCloseButtonStyleAlwaysVisible: 
			self.closeButton.hidden = NO;
			break;
		case InterstitialCloseButtonStyleAlwaysHidden: 
			self.closeButton.hidden = YES;
			break;
		case InterstitialCloseButtonStyleAdControlled: 
			self.closeButton.hidden = !_adWantsNativeCloseButton;
			break;
		default: break;
	}
    
    [self.view bringSubviewToFront:self.closeButton];
}

#pragma mark -

- (void)setKeywords:(NSString *)words
{
	_adView.keywords = words;
}

- (NSString *)keywords
{
	return _adView.keywords;
}

- (void)setLocation:(CLLocation *)loc {
	_adView.location = loc;
}

- (CLLocation *)location {
	return _adView.location;
}

- (void)setLocationEnabled:(BOOL)enabled {
	_adView.locationEnabled = enabled;
}

- (BOOL)locationEnabled {
	return _adView.locationEnabled;
}

- (void)setLocationPrecision:(NSUInteger)precision {
	_adView.locationPrecision = precision;
}

- (NSUInteger)locationPrecision {
	return _adView.locationPrecision;
}

- (void)closeButtonPressed
{
	// Restore previous status/navigation bar state.
	[[UIApplication sharedApplication] setStatusBarHidden:_statusBarWasHidden];
	[self.navigationController setNavigationBarHidden:_navigationBarWasHidden animated:NO];
	
	[self interstitialWillDisappearForAdapter:nil];
	[self.parent dismissInterstitial:self];
}

- (void)loadAd
{
	_ready = NO;
	[_adView loadAd];
}

- (void)show
{	
	if (self.currentAdapter != nil)
	{
		[self.currentAdapter showInterstitialFromViewController:self.parent];
	}
	else 
	{
		[self interstitialWillAppearForAdapter:nil];
		[self presentInterstitialModalViewController];
		[self interstitialDidAppearForAdapter:nil];
	}
}

- (void)presentInterstitialModalViewController
{
	// Track the previous state of the status bar, so that we can restore it.
	_statusBarWasHidden = [UIApplication sharedApplication].statusBarHidden;
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	// Likewise, track the previous state of the navigation bar.
	_navigationBarWasHidden = self.navigationController.navigationBarHidden;
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	[self.parent presentModalViewController:self animated:YES];
}

- (NSArray *)locationDescriptionPair {
	return [_adView locationDescriptionPair];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	if (_orientationType == InterstitialOrientationTypePortrait)
		return (interfaceOrientation == UIInterfaceOrientationPortrait || 
				interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
	else if (_orientationType == InterstitialOrientationTypeLandscape)
		return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
				interfaceOrientation == UIInterfaceOrientationLandscapeRight);
	else return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	// Forward the orientation event to the ad view, passing in our current orientation.
	[_adView rotateToOrientation:self.interfaceOrientation];
}

#pragma mark -
#pragma mark MPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
	return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
	_ready = YES;
	
	if ([self.parent respondsToSelector:@selector(interstitialDidLoadAd:)])
		[self.parent interstitialDidLoadAd:self];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
	_ready = NO;
	
	if ([self.parent respondsToSelector:@selector(interstitialDidFailToLoadAd:)])
		[self.parent interstitialDidFailToLoadAd:self];
}

- (void)willPresentModalViewForAd:(MPAdView *)view
{
	if ([self.parent respondsToSelector:@selector(willPresentModalViewForAd:)])
		[self.parent willPresentModalViewForAd:view];
}

- (void)didDismissModalViewForAd:(MPAdView *)view
{
	if ([self.parent respondsToSelector:@selector(didDismissModalViewForAd:)])
		[self.parent didDismissModalViewForAd:view];
}

- (void)adView:(MPAdView *)view didReceiveResponseParams:(NSDictionary *)params
{
	NSString *closeButtonChoice = [params objectForKey:kCloseButtonHeaderKey];
	_adWantsNativeCloseButton = ![closeButtonChoice isEqualToString:kCloseButtonNone];
	[self layoutCloseButton];
	
	// Set the allowed orientations.
	NSString *orientationChoice = [params objectForKey:kOrientationHeaderKey];
	if ([orientationChoice isEqualToString:kOrientationPortraitOnly])
		_orientationType = InterstitialOrientationTypePortrait;
	else if ([orientationChoice isEqualToString:kOrientationLandscapeOnly])
		_orientationType = InterstitialOrientationTypeLandscape;
	else 
		_orientationType = InterstitialOrientationTypeBoth;
	
	NSString *adapterType = ([[params objectForKey:@"X-Adtype"] isEqualToString:@"mraid"]) ? 
		@"mraid" : [params objectForKey:@"X-Fulladtype"];

	if (!adapterType || [adapterType isEqualToString:@""] || 
		[adapterType isEqualToString:@"html"]) {
		return;
	}

	NSString *classString = [[MPAdapterMap sharedAdapterMap] classStringForAdapterType:adapterType];
	Class cls = NSClassFromString(classString);
	if (cls != nil)
	{
		[self.currentAdapter unregisterDelegate];	
		self.currentAdapter = [(MPBaseInterstitialAdapter *)
							   [[cls alloc] initWithInterstitialAdController:self] autorelease];
		[self.currentAdapter _getAdWithParams:params];
	}
	else 
	{
		// TODO: Generate error.
		[self adapter:nil didFailToLoadAdWithError:nil];
	}
}

- (void)adViewShouldClose:(MPAdView *)view
{
	[self closeButtonPressed];
}

- (void)customEventDidLoadAd {
  _adView.adManager.isLoading = NO;
  [_adView.adManager trackImpression];
}

- (void)customEventDidFailToLoadAd {
  [_adView.adManager adapter:nil didFailToLoadAdWithError:nil];
}

- (void)customEventActionWillBegin {
  [_adView.adManager trackClick];
}

#pragma mark -
#pragma mark MPBaseInterstitialAdapterDelegate

- (void)adapterDidFinishLoadingAd:(MPBaseInterstitialAdapter *)adapter
{	
	_ready = YES;
	_adView.adManager.isLoading = NO;
	if ([self.parent respondsToSelector:@selector(interstitialDidLoadAd:)])
		[self.parent interstitialDidLoadAd:self];
}

- (void)adapter:(MPBaseInterstitialAdapter *)adapter didFailToLoadAdWithError:(NSError *)error
{
	_ready = NO;
	MPLogError(@"Interstitial adapter (%p) failed to load ad. Error: %@", adapter, error);
	
	// Dispose of the current adapter, because we don't want it to try loading again.
	[self.currentAdapter unregisterDelegate];
	self.currentAdapter = nil;
	
	[_adView.adManager adapter:nil didFailToLoadAdWithError:error];
}

- (void)adapter:(MPBaseInterstitialAdapter *)adapter requestsPresentationForView:(UIView *)content
{
	// Replace the default ad view with the one passed as an argument.
	[_adView removeFromSuperview];
	content.frame = self.view.bounds;
	content.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:content];
    [self layoutCloseButton];

	[self interstitialWillAppearForAdapter:adapter];
	[self presentInterstitialModalViewController];
	[self interstitialDidAppearForAdapter:adapter];
}

- (void)adapter:(MPBaseInterstitialAdapter *)adapter requestsDismissalOfView:(UIView *)content
{
	[self closeButtonPressed];
}

- (void)interstitialWillAppearForAdapter:(MPBaseInterstitialAdapter *)adapter
{
	[_adView.adManager trackImpression];
	if ([self.parent respondsToSelector:@selector(interstitialWillAppear:)])
		[self.parent interstitialWillAppear:self];
}

- (void)interstitialDidAppearForAdapter:(MPBaseInterstitialAdapter *)adapter
{
	if ([self.parent respondsToSelector:@selector(interstitialDidAppear:)])
		[self.parent interstitialDidAppear:self];
}

- (void)interstitialWillDisappearForAdapter:(MPBaseInterstitialAdapter *)adapter
{
	if ([self.parent respondsToSelector:@selector(interstitialWillDisappear:)])
		[self.parent interstitialWillDisappear:self];
}

- (void)interstitialDidDisappearForAdapter:(MPBaseInterstitialAdapter *)adapter
{
	if ([self.parent respondsToSelector:@selector(interstitialDidDisappear:)])
		[self.parent interstitialDidDisappear:self];
}

- (void)interstitialWasTappedForAdapter:(MPBaseInterstitialAdapter *)adapter
{
    [_adView.adManager trackClick];
}

- (void)interstitialDidExpireForAdapter:(MPBaseInterstitialAdapter *)adapter
{
    _ready = NO;
    if ([self.parent respondsToSelector:@selector(interstitialDidExpire:)])
        [self.parent interstitialDidExpire:self];
}

#pragma mark -

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
	self.closeButton = nil;
}

@end
