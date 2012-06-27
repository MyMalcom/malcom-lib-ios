//
//  MPMraidInterstitialAdapter.m
//  MoPub
//
//  Created by Andrew He on 12/11/11.
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPMraidInterstitialAdapter.h"
#import "MPInterstitialAdController.h"
#import "MPLogging.h"

@implementation MPMraidInterstitialAdapter

- (void)getAdWithParams:(NSDictionary *)params {
    NSData *payload = [params objectForKey:@"payload"];
    NSMutableString *payloadString = [[NSMutableString alloc] initWithData:payload 
                                                                  encoding:NSUTF8StringEncoding];
    
    CGFloat width = [(NSString *)[params objectForKey:@"adWidth"] floatValue];
	CGFloat height = [(NSString *)[params objectForKey:@"adHeight"] floatValue];
    
    _adView = [[MRAdView alloc] initWithFrame:CGRectMake(0, 0, width, height) 
                              allowsExpansion:NO
                             closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                placementType:MRAdViewPlacementTypeInterstitial];
    _adView.delegate = self;
    [_adView loadCreativeWithHTMLString:payloadString baseURL:nil];
    
    [payloadString release];
}

- (void)dealloc {
    _adView.delegate = nil;
    [_adView release];
    [super dealloc];
}

- (void)showInterstitialFromViewController:(UIViewController *)controller {
    if (_loaded) {
        [_interstitialAdController adapter:self requestsPresentationForView:_adView];
    }
}

#pragma mark -
#pragma mark MRAdViewControllerDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return _interstitialAdController;
}

- (void)adDidLoad:(MRAdView *)adView {
    _loaded = YES;
    [_interstitialAdController adapterDidFinishLoadingAd:self];
}

- (void)adDidFailToLoad:(MRAdView *)adView {
    _loaded = NO;
    [_interstitialAdController adapter:self didFailToLoadAdWithError:nil];
}

- (void)adWillClose:(MRAdView *)adView {
    [_interstitialAdController adapter:self requestsDismissalOfView:adView];
}

- (void)ad:(MRAdView *)adView didRequestCustomCloseEnabled:(BOOL)enabled {
    _interstitialAdController.adWantsNativeCloseButton = !enabled;
}

@end
