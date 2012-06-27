
// Copyright 2011 madvertise Mobile Advertising GmbH
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "MadvertiseView.h"

@implementation MadvertiseView

@synthesize currentAd;
@synthesize request;
@synthesize currentView;
@synthesize timer;
@synthesize conn;
@synthesize receivedData;
@synthesize madDelegate;

NSString * const MadvertiseAdClass_toString[] = {
  @"mma",
  @"medium_rectangle",
  @"leaderboard",
  @"fullscreen",
  @"portrait",
  @"landscape",
  @"rich_media",
  @"iphone_preloader",
  @"ipad_preloader"
};

int const MadvertiseAdClass_toWidth[] = {
    320,
    300,
    728,
    768,
    766,
    1024,
    320,
    320,
    1024
};

int const MadvertiseAdClass_toHeight[] = {
    53,
    250,
    90,
    768,
    66,
    66,
    480,
    460,
    748
};

// METHODS
- (void) dealloc {
  MadLog(@"Call dealloc in MadvertiseView");
  
  [[NSNotificationCenter defaultCenter] removeObserver: self name:UIApplicationDidEnterBackgroundNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver: self name:UIApplicationDidBecomeActiveNotification object:nil];

  [self.conn cancel];
  self.conn = nil;
  self.request = nil;
  self.receivedData = nil;
    
  if (mraidView) {
    mraidView.delegate = nil;
  }

  [self stopTimer];

  if (currentView) {
      if ([currentView isKindOfClass:[UIWebView class]]) {
          ((UIWebView *)currentView).delegate = nil;
          if ([currentView respondsToSelector:@selector(stopLoading)]) {
              [((UIWebView *)currentView) stopLoading];
          }
      }
      [currentView release];currentView = nil;
  }
  
  [currentAd release];currentAd = nil;
  [lock release];lock = nil;
  [madDelegate release]; madDelegate = nil;

  [super dealloc];
}

+ (MadvertiseView*)loadRichMediaAdWithDelegate:(id<MadvertiseDelegationProtocol>)delegate {
  return [self loadAdWithDelegate:delegate withClass:MadvertiseAdClassRichMedia placementType:MRAdViewPlacementTypeInterstitial secondsToRefresh:-1];
}

+ (MadvertiseView*)loadAdWithDelegate:(id<MadvertiseDelegationProtocol>)delegate withClass:(MadvertiseAdClass)adClassValue secondsToRefresh:(int)secondsToRefresh {
    return [self loadAdWithDelegate:delegate withClass:adClassValue placementType:MRAdViewPlacementTypeInline secondsToRefresh:secondsToRefresh];
}

+ (MadvertiseView*)loadAdWithDelegate:(id<MadvertiseDelegationProtocol>)delegate withClass:(MadvertiseAdClass)adClassValue placementType:(MRAdViewPlacementType) type secondsToRefresh:(int)secondsToRefresh {
  BOOL enableDebug = NO;

#ifdef DEBUG
  enableDebug = YES;
#endif

  // debugging
  if([delegate respondsToSelector:@selector(debugEnabled)]){
    enableDebug = [delegate debugEnabled];
  }

  // Download-Tracker
  if([delegate respondsToSelector:@selector(downloadTrackerEnabled)]){
    if([delegate downloadTrackerEnabled] == YES){
      [MadvertiseTracker setDebugMode: enableDebug];
      [MadvertiseTracker setProductToken:[delegate appId]];
      [MadvertiseTracker enable];
    }
  }
    
  // handle special rich media case
  if (adClassValue == MadvertiseAdClassRichMedia) {
      secondsToRefresh = -1;
  }
    
    return [[[MadvertiseView alloc] initWithDelegate:delegate withClass:adClassValue placementType:type secondsToRefresh:secondsToRefresh] autorelease];
}

+ (void) handlerWithObserver:(id) observer AndSelector:(SEL) selector ForEvent:(NSString*) event {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:event object:nil];
}

- (void)place_at_x:(int) x_pos y:(int) y_pos {
    x = x_pos;
    y = y_pos;
    
    if (currentAdClass == MadvertiseAdClassRichMedia) {
        x = 0;
        y = 0;
    }
}

// helper method for initialization
- (MadvertiseView*)initWithDelegate:(id<MadvertiseDelegationProtocol>)delegate withClass:(MadvertiseAdClass)adClassValue placementType:(MRAdViewPlacementType) type secondsToRefresh:(int)secondsToRefresh {

  if ((self = [super init])) {
    MadLog(@"madvertise SDK %@", MADVERTISE_SDK_VERION);

    self.clipsToBounds = YES;
    
    currentView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self addSubview: currentView];
    [self setHidden:YES];
    
    currentAdClass      = adClassValue;
    interval            = secondsToRefresh;
    request             = nil;
    receivedData        = nil;
    responseCode        = 200;
    self.timer          = nil;
    isExpanded          = false;
    placementType       = type;
    madDelegate         = delegate;
    [madDelegate retain];

    // load first ad
    lock = [[NSLock alloc] init];
    [self loadAd];

    animationDuration = 0.75;

    if ([madDelegate respondsToSelector:@selector(durationOfBannerAnimation)]) {
      animationDuration = [madDelegate durationOfBannerAnimation];
    }

    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(stopTimer) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(createAdReloadTimer) name:UIApplicationDidBecomeActiveNotification object:nil];
  }

  return self;
}

#pragma mark - server connection handling

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    MadLog(@"%@ %i", @"Received response code: ", [response statusCode]);
    responseCode = [response statusCode];
    [receivedData setLength:0];
    
    if ([madDelegate respondsToSelector:@selector(debugEnabled)] && [madDelegate debugEnabled]) {
        MadLog(@"%@",[[response allHeaderFields] objectForKey:@"X-Madvertise-Debug"]);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    MadLog(@"Received data from Ad Server");
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    MadLog(@"Failed to receive ad");
    MadLog(@"%@",[error description]);

    // dispatch status notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseAdLoadFailed" object:[NSNumber numberWithInt:responseCode]];

    self.request = nil;
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (responseCode == 200 && !isExpanded) {
        MadLog(@"Deserializing json");
        
        NSDictionary *dictionary = [receivedData objectFromJSONData];

        MadLog(@"Creating ad");
        [currentAd release];
        currentAd = [[MadvertiseAd alloc] initFromDictionary:dictionary];
      
        [self displayView];
    } else if (!isExpanded) {
        // dispatch status notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseAdLoadFailed" object:[NSNumber numberWithInt:responseCode]];
    }

    self.request = nil;
    self.receivedData = nil;
}


// generate request, that is send to the ad server
- (void)loadAd {
    [self retain];
    [lock lock];

    if (self.request){
      MadLog(@"loadAd - returning because another request is running");
      [lock unlock];
      [self release];
      return;
    }

    NSString *server_url = @"http://ad.madvertise.de";
    if (madDelegate != nil && [madDelegate respondsToSelector:@selector(adServer)]) {
      server_url = [madDelegate adServer];
    }
    MadLog(@"Using url: %@", server_url);

    // always supported request parameter
    if (madDelegate == nil || ![madDelegate respondsToSelector:@selector(appId)]) {
      MadLog(@"delegate does not respond to appId ! return ...");
      [self release];
      return;
    }

    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/site/%@", server_url, [madDelegate appId]]];
    MadLog(@"AppId : %@", [madDelegate appId]);

    MadLog(@"Init new request");
    self.request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];

    NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
    [headers setValue:@"application/x-www-form-urlencoded; charset=utf-8" forKey:@"Content-Type"];
    [headers setValue:@"application/vnd.madad+json; version=3" forKey:@"Accept"];

    MadLog(@"ua: %@", UserAgentString());

    NSMutableDictionary* post_params = [[NSMutableDictionary alloc] init];
    self.receivedData = [NSMutableData data];
    
    CGSize parent_size = [self getParentViewDimensions];
    CGSize screen_size = [MadvertiseUtilities getScreenResolution];

    [post_params setValue: @"true"                                       forKey:MADVERTISE_APP_KEY];
    [post_params setValue: [MadvertiseUtilities getMacMD5Hash]           forKey:MADVERTISE_MACMD5_KEY];
    [post_params setValue: [MadvertiseUtilities getMacSHA1Hash]          forKey:MADVERTISE_MACSHA1_KEY];
    [post_params setValue: [MadvertiseUtilities getIP]                   forKey:MADVERTISE_IP_KEY];
    [post_params setValue: @"json"                                       forKey:MADVERTISE_FORMAT_KEY];
    [post_params setValue: @"iPhone-SDK "                                forKey:MADVERTISE_REQUESTER_KEY];
    [post_params setValue: MADVERTISE_SDK_VERION                         forKey:MADVERTISE_SDK_VERION_KEY];
    [post_params setValue: [MadvertiseUtilities getTimestamp]            forKey:MADVERTISE_TIMESTAMP_KEY];
    [post_params setValue: MadvertiseAdClass_toString[currentAdClass]    forKey:MADVERTISE_BANNER_TYPE_KEY];
    [post_params setValue: [MadvertiseUtilities getAppName]              forKey:MADVERTISE_APP_NAME_KEY];
    [post_params setValue: [MadvertiseUtilities getAppVersion]           forKey:MADVERTISE_APP_VERSION_KEY];
    [post_params setValue: [NSNumber numberWithFloat:parent_size.width]  forKey:MADVERTISE_PARENT_WIDTH_KEY];
    [post_params setValue: [NSNumber numberWithFloat:parent_size.height] forKey:MADVERTISE_PARENT_HEIGHT_KEY];
    [post_params setValue: [NSNumber numberWithFloat:screen_size.width]  forKey:MADVERTISE_DEVICE_WIDTH_KEY];
    [post_params setValue: [NSNumber numberWithFloat:screen_size.height] forKey:MADVERTISE_DEVICE_HEIGHT_KEY];
    [post_params setValue: [MadvertiseUtilities getDeviceOrientation]    forKey:MADVERTISE_ORIENTATION_KEY];
    [post_params setValue: [UserAgentString() urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:MADVERTISE_USER_AGENT_KEY];
    [post_params setValue: (([madDelegate respondsToSelector:@selector(debugEnabled)] && [madDelegate debugEnabled]) ? @"true" : @"false") forKey:MADVERTISE_DEBUG_KEY];
    
    if (!([madDelegate respondsToSelector:@selector(mRaidDisabled)] && [madDelegate mRaidDisabled])) {
        [post_params setValue: @"true"                                forKey:MADVERTISE_MRAID_KEY];
    }
    if ([madDelegate respondsToSelector:@selector(location)]) {
        CLLocationCoordinate2D location = [madDelegate location];
        [post_params setValue:[NSString stringWithFormat:@"%.6f", location.longitude] forKey:MADVERTISE_LNG_KEY];
        [post_params setValue:[NSString stringWithFormat:@"%.6f", location.latitude] forKey:MADVERTISE_LAT_KEY];
    }
    if ([madDelegate respondsToSelector:@selector(gender)]) {
        NSString *gender = [madDelegate gender];
        [post_params setValue:gender forKey:MADVERTISE_GENDER_KEY];
        MadLog(@"gender: %@", gender);
    }
    if ([madDelegate respondsToSelector:@selector(age)]) {
        NSString *age = [madDelegate age];
        [post_params setValue:age forKey:MADVERTISE_AGE_KEY];
        MadLog(@"%@", age);
    }

    NSString *body = @"";
    unsigned int n = 0;
    
    for (NSString* key in post_params) {
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@", key, [post_params objectForKey:key]]];
        if (++n != [post_params count] ) {
            body = [body stringByAppendingString:@"&"];
        }
    }

    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    MadLog(@"Sending request");

    self.conn = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    MadLog(@"Request send");

    [headers release];
    [post_params release];
    [lock unlock];
    [self release];
}

- (void)openInSafariButtonPressed:(id)sender {
    MadLog(@"openInSafariButtonPressed called");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentAd.clickUrl]];
}

- (void)stopTimer {
    if (self.timer && [timer isValid]) {
        MadLog(@"Stop Ad reload timer");
        [self.timer invalidate];
    }
}

- (void)createAdReloadTimer {
    // prepare automatic refresh
    if (interval > 0) {
        MadLog(@"Init Ad reload timer");
        [self stopTimer];
        self.timer = [NSTimer scheduledTimerWithTimeInterval: interval target: self selector: @selector(timerFired:) userInfo: nil repeats: YES];
    }
}

// ad has been touched, open click_url from he current app according to click_action
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    MadLog(@"touchesBegan");
    if (currentAd.shouldOpenInAppBrowser) {
        [self openInAppBrowserWithUrl: currentAd.clickUrl];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentAd.clickUrl]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//  [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//  [super touchesEnded:touches withEvent:event];
}

// Refreshing the ad
- (void)timerFired: (NSTimer *) theTimer {
  if (madDelegate != nil && [madDelegate respondsToSelector:@selector(appId)]) {
    MadLog(@"Ad reloading");
    [self loadAd];
  }
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    if (aWebView != currentView) {
        [self swapView:aWebView oldView:currentView];
    }
    
    [self setHidden:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseAdLoaded" object:[NSNumber numberWithInt:responseCode]];
}

- (void) displayView {
    MadLog(@"Display view");
    if (isExpanded) {
        return;
    }
    
    if (currentAd == nil) {
        MadLog(@"No ad to show");
        [self setUserInteractionEnabled:NO];
        return;
    }
    
    [self setUserInteractionEnabled:YES];

    self.frame = CGRectMake(x, y , ([currentAd width] != 0) ? [currentAd width] : MadvertiseAdClass_toWidth[currentAdClass], ([currentAd height] != 0) ? [currentAd height] : MadvertiseAdClass_toHeight[currentAdClass]);
    
    CGRect frame = CGRectMake(0, 0, ([currentAd width] != 0) ? [currentAd width] : MadvertiseAdClass_toWidth[currentAdClass], ([currentAd height] != 0) ? [currentAd height] : MadvertiseAdClass_toHeight[currentAdClass]);
    
    if ([currentAd isRichMedia]) {
        mraidView = [[MRAdView alloc] initWithFrame:frame 
                                                allowsExpansion:YES
                                                closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                                placementType:placementType];
        mraidView.delegate = self;
        
        if ([currentAd isLoadableViaUrl]) {
            [mraidView loadCreativeFromURL:[currentAd url]];
        }
        else {
            [mraidView loadCreativeWithHTMLString:[currentAd to_html] baseURL:nil];
        }
    }
    else {
        UIWebView* view = [[UIWebView alloc] initWithFrame:frame];
        [view setUserInteractionEnabled:NO];
        view.delegate = self;
        [view loadHTMLString:[currentAd to_html] baseURL:nil];
    }
}

- (void)openInAppBrowserWithUrl: (NSString*)url {
    [self stopTimer];
    isExpanded = true;
    
    if ([madDelegate respondsToSelector:@selector(inAppBrowserWillOpen)]) {
        [madDelegate inAppBrowserWillOpen];
    }
    
    MPAdBrowserController *browser = [[MPAdBrowserController alloc] initWithURL:[NSURL URLWithString:url] delegate:self];
    [[self viewControllerForPresentingModalView] presentModalViewController:browser animated:YES];
    [browser release];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)urlRequest navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [urlRequest URL];
    NSString *urlStr = [url absoluteString];
  
    if ([urlStr rangeOfString:@"inappbrowser"].location != NSNotFound) {
        [self openInAppBrowserWithUrl:urlStr];
    } else if ([urlStr rangeOfString:@"exitapp"].location != NSNotFound) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }
    
    return YES;   
}

- (void)swapView:(UIWebView*)newView oldView:(UIWebView*) oldView {
    MadvertiseAnimationClass animationTyp;
  
    if ([madDelegate respondsToSelector:@selector(bannerAnimationTyp)]) {
        animationTyp = [madDelegate bannerAnimationTyp];
    } else {
        animationTyp = MadvertiseAnimationClassNone;
    }

    if (currentAdClass == MadvertiseAdClassRichMedia) {
        animationTyp = MadvertiseAnimationClassNone;
    }
    
    if (animationTyp == MadvertiseAnimationClassNone) {
      [self addSubview:newView];
      [self bringSubviewToFront:newView];
      [oldView removeFromSuperview];
      currentView = newView;
      return;
    }
  
    UIViewAnimationTransition transition = UIViewAnimationTransitionNone;
  
    float newStartAlpha = 1;
    float newEndAlpha = 1;
    float oldEndAlpha = 1;

    CGRect newStart = [newView frame];
    CGRect newEnd = [newView frame];
    CGRect oldEnd = [oldView frame];
  
    switch (animationTyp) {
        case MadvertiseAnimationClassLeftToRight:
            newStart.origin = CGPointMake(-newStart.size.width, newStart.origin.y);
            oldEnd.origin = CGPointMake(oldEnd.origin.x + oldEnd.size.width, oldEnd.origin.y);
            break;
        case MadvertiseAnimationClassTopToBottom:
            newStart.origin = CGPointMake(newStart.origin.x, -newStart.size.height);
            oldEnd.origin = CGPointMake(oldEnd.origin.x, oldEnd.origin.y + oldEnd.size.height);
            break;
        case MadvertiseAnimationClassCurlDown:
            transition = UIViewAnimationTransitionCurlDown;
            break;
        case MadvertiseAnimationClassNone:
            break;
        case MadvertiseAnimationClassFade:
            newStartAlpha = 0;
            newEndAlpha = 1;
            oldEndAlpha = 0;
            break;
        default:
            break;
    }
  
    newView.frame = newStart;
    newView.alpha = newStartAlpha;
  
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:animationDuration];
  
    if(transition) {
        [UIView setAnimationTransition:transition forView:self cache:YES];
    }
  
    newView.alpha = newEndAlpha;
    oldView.alpha = oldEndAlpha;
    newView.frame = newEnd;
    oldView.frame = oldEnd;
    [self addSubview:newView];
    [newView release];
 
    [UIView setAnimationDelegate:oldView];
    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    [UIView commitAnimations];

    if ([currentView isKindOfClass:[UIWebView class]]) {
        ((UIWebView *)currentView).delegate = nil;
        if ([currentView respondsToSelector:@selector(stopLoading)]) {
            [((UIWebView *)currentView) stopLoading];
        }
    }
    
    self.currentView = newView;
}

- (UIViewController *)viewControllerForPresentingModalView {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark MRAdViewControllerDelegate

- (void)closeButtonPressed {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdClosed" object:nil];
}

- (void)adDidLoad:(MRAdView *)adView {
    [self setHidden:NO];
    [self swapView:adView oldView:currentView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseAdLoaded" object:[NSNumber numberWithInt:responseCode]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdDidLoad" object:adView];
}

- (void)adDidFailToLoad:(MRAdView *)adView {
    [self setHidden:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdDidFailToload" object:adView];
}

- (void)appShouldSuspendForAd:(MRAdView *)adView {
    [self stopTimer];
    isExpanded = true;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAppShouldSuspend" object:adView];
}

- (void)appShouldResumeFromAd:(MRAdView *)adView {
    isExpanded = false;
    [self createAdReloadTimer];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAppShouldResume" object:adView];
}

// Called just before the ad is displayed on-screen.
- (void)adWillShow:(MRAdView *)adView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdWillShow" object:adView];
}

// Called just after the ad has been displayed on-screen.
- (void)adDidShow:(MRAdView *)adView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdDidShow" object:adView];
}

// Called just before the ad is hidden.
- (void)adWillHide:(MRAdView *)adView {
    [self stopTimer];
    isExpanded = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdWillHide" object:adView];
}

// Called just after the ad has been hidden.
- (void)adDidHide:(MRAdView *)adView {    
    self.frame = CGRectMake(x, y , 0, 0);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdDidHide" object:adView];
}

// Called just before the ad expands.
- (void)willExpandAd:(MRAdView *)adView toFrame:(CGRect)frame {
    [self stopTimer];
    isExpanded = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdWillExpand" object:adView];
}

// Called just after the ad has expanded.
- (void)didExpandAd:(MRAdView *)adView toFrame:(CGRect)frame {
    isExpanded = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdDidExpand" object:adView];
}

// Called just before the ad closes.
- (void)adWillClose:(MRAdView *)adView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdWillClose" object:adView];
}

// Called just after the ad has closed.
- (void)adDidClose:(MRAdView *)adView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdDidClose" object:adView];
}

- (void)ad:(MRAdView *)adView didRequestCustomCloseEnabled:(BOOL)enabled {
    if (enabled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdDidRequestCustomClose" object:adView];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MadvertiseMRaidAdDidNotRequestCustomClose" object:adView];
    }
}

#pragma mark -
#pragma mark MPAdBrowserControllerDelegate

- (void)dismissBrowserController:(MPAdBrowserController *)browserController {
    [self dismissBrowserController:browserController animated:YES];
}

- (void)dismissBrowserController:(MPAdBrowserController *)browserController animated:(BOOL)animated {
	[[self viewControllerForPresentingModalView] dismissModalViewControllerAnimated:animated];
    
    if ([madDelegate respondsToSelector:@selector(inAppBrowserClosed)]) {
        [madDelegate inAppBrowserClosed];
    }
    
    isExpanded = false;
    [self createAdReloadTimer];
}

#pragma mark - private methods section

- (CGSize) getParentViewDimensions {

  if([self superview] != nil){
    UIView *parent = [self superview];
    return CGSizeMake(parent.frame.size.width, parent.frame.size.height);
  }
  return CGSizeMake(0, 0);
}

@end
