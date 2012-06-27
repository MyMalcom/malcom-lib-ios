//
//  MRAdView.m
//  MoPub
//
//  Created by Andrew He on 12/20/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import "MRAdView.h"
#import "UIWebView+MPAdditions.h"
#import "MPLogging.h"
#import "MRAdViewBrowsingController.h"
#import "MRAdViewDisplayController.h"
#import "MRCommand.h"
#import "MRProperty.h"
#import "MPGlobal.h"

static NSString * const kExpandableCloseButtonImageName = @"MPCloseButtonX.png";
static NSString * const kMraidURLScheme = @"mraid";

@interface MRAdView ()

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) MRAdViewBrowsingController *browsingController;
@property (nonatomic, retain) MRAdViewDisplayController *displayController;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)convertFragmentToFullPayload:(NSMutableString *)fragment;
- (NSString *)executeJavascript:(NSString *)javascript withVarArgs:(va_list)args;
- (BOOL)isOnscreen;
- (void)layoutCloseButton;
- (void)fireChangeEventForProperty:(MRProperty *)property;
- (void)fireChangeEventsForProperties:(NSArray *)properties;
- (void)fireErrorEventForAction:(NSString *)action withMessage:(NSString *)message;
- (void)fireReadyEvent;
- (void)fireNativeCommandCompleteEvent:(NSString *)command;
- (void)initializeJavascriptState;
- (BOOL)tryProcessingURLStringAsCommand:(NSString *)urlString;
- (BOOL)tryProcessingCommand:(NSString *)command parameters:(NSDictionary *)parameters;

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

@implementation MRAdView
@synthesize delegate = _delegate;
@synthesize usesCustomCloseButton = _usesCustomCloseButton;
@synthesize expanded = _expanded;
@synthesize data = _data;
@synthesize browsingController = _browsingController;
@synthesize displayController = _displayController;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame 
               allowsExpansion:YES 
              closeButtonStyle:MRAdViewCloseButtonStyleAdControlled 
                 placementType:MRAdViewPlacementTypeInline];
}

- (id)initWithFrame:(CGRect)frame allowsExpansion:(BOOL)expansion 
   closeButtonStyle:(MRAdViewCloseButtonStyle)style placementType:(MRAdViewPlacementType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        _webView = [[UIWebView alloc] initWithFrame:frame];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
            UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.clipsToBounds = YES;
        _webView.delegate = self;
        _webView.opaque = NO;
        [_webView mp_setScrollable:NO];
        
        if ([_webView respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
            [_webView setAllowsInlineMediaPlayback:YES];
        }
        
        if ([_webView respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
            [_webView setMediaPlaybackRequiresUserAction:NO];
        }
        
        [self addSubview:_webView];
        
        _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _closeButton.frame = CGRectMake(0, 0, 50, 50);
        UIImage *image = [UIImage imageNamed:kExpandableCloseButtonImageName];
        [_closeButton setImage:image forState:UIControlStateNormal];
        
        _allowsExpansion = expansion;
        _closeButtonStyle = style;
        _placementType = type;
        
        _browsingController = [[MRAdViewBrowsingController alloc] initWithAdView:self];
        _displayController = [[MRAdViewDisplayController alloc] initWithAdView:self
                                                               allowsExpansion:expansion 
                                                              closeButtonStyle:style];
        
        [_closeButton addTarget:_displayController action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        if (![self hideCloseButtinIndefaultState]) {
            [self layoutCloseButton];
        }
    }
    return self;
}

- (void)dealloc {
    _webView.delegate = nil;
    if ([_webView respondsToSelector:@selector(stopLoading)]) {
        [_webView stopLoading];
    }
    [_webView release];
    [_closeButton release];
    [_data release];
    [_browsingController release];
    [_displayController release];
    [super dealloc];
}

#pragma mark - Public

- (void)setDelegate:(id<MRAdViewDelegate>)delegate {
    [_closeButton removeTarget:delegate
                        action:NULL
              forControlEvents:UIControlEventTouchUpInside];
    
    _delegate = delegate;
    
    [_closeButton addTarget:_delegate 
                     action:@selector(closeButtonPressed)
           forControlEvents:UIControlEventTouchUpInside];
    
    _browsingController.viewControllerForPresentingModalView =
        [_delegate viewControllerForPresentingModalView];
}

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;
    [self layoutCloseButton];
}

- (void)setUsesCustomCloseButton:(BOOL)shouldUseCustomCloseButton {
    _usesCustomCloseButton = shouldUseCustomCloseButton;
    [self layoutCloseButton];
}

- (NSString *)executeJavascript:(NSString *)javascript, ... {
    va_list args;
    va_start(args, javascript);
    NSString *result = [self executeJavascript:javascript withVarArgs:args];
    va_end(args);
    return result;
}

- (BOOL)isViewable {
    return (!self.hidden && self.superview && [self isOnscreen]);
}

- (void)loadCreativeFromURL:(NSURL *)url {
    [_displayController revertViewToDefaultState];
    _isLoading = YES;
    loadedUrl = url;
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadCreativeWithHTMLString:(NSString *)html baseURL:(NSURL *)url {
    [_displayController revertViewToDefaultState];
    _isLoading = YES;
    [self loadHTMLString:html baseURL:url];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation {
    [_displayController rotateToOrientation:newOrientation];
}

- (NSString *)placementType {
    switch (_placementType) {
        case MRAdViewPlacementTypeInline: return @"inline";
        case MRAdViewPlacementTypeInterstitial: return @"interstitial";
        default: return @"unknown";
    }
}

#pragma mark - Javascript Communication API

- (void)fireChangeEventForProperty:(MRProperty *)property {
    NSString *JSON = [NSString stringWithFormat:@"{%@}", property];
    [self executeJavascript:@"window.mraidbridge.fireChangeEvent(%@);", JSON];
    MPLogDebug(@"JSON: %@", JSON);
}

- (void)fireChangeEventsForProperties:(NSArray *)properties {
    NSString *JSON = [NSString stringWithFormat:@"{%@}", 
                      [properties componentsJoinedByString:@", "]];
    [self executeJavascript:@"window.mraidbridge.fireChangeEvent(%@);", JSON];
    MPLogDebug(@"JSON: %@", JSON);
}

- (void)fireErrorEventForAction:(NSString *)action withMessage:(NSString *)message {
    [self executeJavascript:@"window.mraidbridge.fireErrorEvent('%@', '%@');", message, action];
}

- (void)fireReadyEvent {
    [self executeJavascript:@"window.mraidbridge.fireReadyEvent();"];
}

- (void)fireNativeCommandCompleteEvent:(NSString *)command {
    [self executeJavascript:@"window.mraidbridge.nativeCallComplete('%@');", command];
}

- (bool)hideCloseButtinIndefaultState {
    return _placementType == MRAdViewPlacementTypeInline;
}

#pragma mark - Private

- (void)loadRequest:(NSURLRequest *)request {
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        self.data = [NSMutableData data];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    NSString *mraidBundlePath = [[NSBundle mainBundle] pathForResource:@"MRAID" ofType:@"bundle"];
    NSBundle *mraidBundle = [NSBundle bundleWithPath:mraidBundlePath];
    NSString *mraidPath = [mraidBundle pathForResource:@"mraid" ofType:@"js"];
    NSString *mraidString = [NSString stringWithContentsOfFile:mraidPath encoding:NSUTF8StringEncoding error:nil];
    
    [_webView stringByEvaluatingJavaScriptFromString:mraidString];
    [_webView loadHTMLString:string baseURL:baseURL];
}

- (BOOL)isOnscreen {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect frameInWindowCoordinates = [self.superview convertRect:self.frame toView:keyWindow];
    return CGRectIntersectsRect(frameInWindowCoordinates, keyWindow.frame);
}

- (void)convertFragmentToFullPayload:(NSMutableString *)fragment {
    MPLogDebug(@"Fragment detected: converting to full payload.");
    NSString *prepend = @"<html><head>"
    @"<meta name='viewport' content='user-scalable=no; initial-scale=1.0'/>"
    @"</head>"
    @"<body style='margin:0;padding:0;overflow:hidden;background:transparent;'>";
    [fragment insertString:prepend atIndex:0];
    [fragment appendString:@"</body></html>"];
}

- (NSString *)executeJavascript:(NSString *)javascript withVarArgs:(va_list)args {
    NSString *js = [[[NSString alloc] initWithFormat:javascript arguments:args] autorelease];
    
    return [_webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)layoutCloseButton {
    if (!_usesCustomCloseButton) {
        CGRect frame = _closeButton.frame;
        frame.origin.x = CGRectGetWidth(CGRectApplyAffineTransform(self.frame, self.transform)) - 
        _closeButton.frame.size.width;
        _closeButton.frame = frame;
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_closeButton];
        [self bringSubviewToFront:_closeButton];
    } else {
        [_closeButton removeFromSuperview];
    }
}

- (void)initializeJavascriptState {
    MPLogDebug(@"Injecting initial JavaScript state.");
    [self fireChangeEventForProperty:[MRPlacementTypeProperty propertyWithType:_placementType]];
    [_displayController initializeJavascriptState];
    [self fireReadyEvent];
}

- (BOOL)tryProcessingURLStringAsCommand:(NSString *)urlString {
    NSString *scheme = [NSString stringWithFormat:@"%@://", kMraidURLScheme];
    NSString *schemelessUrlString = [urlString substringFromIndex:scheme.length];
    
    NSRange r = [schemelessUrlString rangeOfString:@"?"];
    
    if (r.location == NSNotFound) {
        return [self tryProcessingCommand:schemelessUrlString parameters:nil];
    }
    
    NSString *commandType = [[schemelessUrlString substringToIndex:r.location] lowercaseString];
    NSString *parameterString = [schemelessUrlString substringFromIndex:(r.location + 1)];
    NSDictionary *parameters = MPDictionaryFromQueryString(parameterString);
    
    return [self tryProcessingCommand:commandType parameters:parameters];
}

- (BOOL)tryProcessingCommand:(NSString *)command parameters:(NSDictionary *)parameters {
    MRCommand *cmd = [MRCommand commandForString:command];
    cmd.parameters = parameters;
    cmd.view = self;
    
    BOOL processed = [cmd execute];
    if (!processed) MPLogDebug(@"Unknown command: %@", command);
    
    [self fireNativeCommandCompleteEvent:command];
    
    return processed;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self adDidFailToLoad];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *str = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    
    [self loadHTMLString:str baseURL:loadedUrl];
    [str release];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    NSMutableString *urlString = [NSMutableString stringWithString:[url absoluteString]];
    NSString *scheme = url.scheme;
    
    if ([scheme isEqualToString:kMraidURLScheme]) {
        MPLogDebug(@"Trying to process command: %@", urlString);
        BOOL success = [self tryProcessingURLStringAsCommand:urlString];
        if (success) return NO;
    }
    
    if ([scheme isEqualToString:@"tel"] || [scheme isEqualToString:@"mailto"]) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            return NO;
        }
        return YES;
    } else if ([scheme isEqualToString:@"mopub"]) {
        return NO;
    } else if ([scheme isEqualToString:@"ios-log"]) {
        [urlString replaceOccurrencesOfString:@"%20" 
                                   withString:@" " 
                                      options:NSLiteralSearch 
                                        range:NSMakeRange(0, [urlString length])];
        MPLogDebug(@"Web console: %@", urlString);
        return NO;
    }
    
    if (!_isLoading && navigationType == UIWebViewNavigationTypeOther) {
        BOOL iframe = ![request.URL isEqual:request.mainDocumentURL];
        if (iframe) return YES;
        
        [_browsingController openBrowserWithUrlString:urlString 
                                           enableBack:YES 
                                        enableForward:YES 
                                        enableRefresh:YES];
        return NO;
    }
    
    if (!_isLoading && navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (_isLoading) {
        _isLoading = NO;
        [self adDidLoad];
        [self initializeJavascriptState];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) return;
    _isLoading = NO;
    [self adDidFailToLoad];
}

#pragma mark - Delegation Wrappers

- (void)adDidLoad {
    if ([self.delegate respondsToSelector:@selector(adDidLoad:)]) {
        [self.delegate adDidLoad:self];
    }
}

- (void)adDidFailToLoad {
    if ([self.delegate respondsToSelector:@selector(adDidFailToLoad:)]) {
        [self.delegate adDidFailToLoad:self];
    }
}

- (void)adWillClose {
    if ([self.delegate respondsToSelector:@selector(adWillClose:)]) {
        [self.delegate adWillClose:self];
    }
}

- (void)adWillHide {
    if ([self.delegate respondsToSelector:@selector(adWillHide:)]) {
        [self.delegate adWillHide:self];
    }
}

- (void)adDidHide {
    if ([self.delegate respondsToSelector:@selector(adDidHide:)]) {
        [self.delegate adDidHide:self];
    }
}

- (void)adDidClose {
    if ([self.delegate respondsToSelector:@selector(adDidClose:)]) {
        [self.delegate adDidClose:self];
    }
}

- (void)adWillExpandToFrame:(CGRect)frame {
    if ([self.delegate respondsToSelector:@selector(willExpandAd:toFrame:)]) {
        [self.delegate willExpandAd:self toFrame:frame];
    }
}

- (void)adDidExpandToFrame:(CGRect)frame {
    if ([self.delegate respondsToSelector:@selector(didExpandAd:toFrame:)]) {
        [self.delegate didExpandAd:self toFrame:frame];
    }
}

- (void)adDidRequestCustomCloseEnabled:(BOOL)enabled {
    if ([self.delegate respondsToSelector:@selector(ad:didRequestCustomCloseEnabled:)]) {
        [self.delegate ad:self didRequestCustomCloseEnabled:enabled];
    }
}

- (void)adWillPresentModalView {
    [_displayController additionalModalViewWillPresent];
    
    _modalViewCount++;
    if (_modalViewCount == 1) [self appShouldSuspend];
}

- (void)adDidDismissModalView {
    [_displayController additionalModalViewDidDismiss];
    
    _modalViewCount--;
    NSAssert((_modalViewCount >= 0), @"Modal view count cannot be negative.");
    if (_modalViewCount == 0) [self appShouldResume];
}

- (void)appShouldSuspend {
    if ([self.delegate respondsToSelector:@selector(appShouldSuspendForAd:)]) {
        [self.delegate appShouldSuspendForAd:self];
    }
}

- (void)appShouldResume {
    if ([self.delegate respondsToSelector:@selector(appShouldResumeFromAd:)]) {
        [self.delegate appShouldResumeFromAd:self];
    }
}

- (void)adViewableDidChange:(BOOL)viewable {
    [self fireChangeEventForProperty:[MRViewableProperty propertyWithViewable:viewable]];
}

@end
