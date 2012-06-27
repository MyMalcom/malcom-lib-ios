//
//  MPMraidAdapter.m
//  MoPub
//
//  Created by Andrew He on 10/29/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import "MPMraidAdapter.h"
#import "MPConstants.h"

@implementation MPMraidAdapter

- (void)getAdWithParams:(NSDictionary *)params
{
	NSData *payload = [params objectForKey:@"payload"];
    NSMutableString *payloadString = [[NSMutableString alloc] initWithData:payload 
                                                                  encoding:NSUTF8StringEncoding];
    
    CGFloat width = [(NSString *)[params objectForKey:@"adWidth"] floatValue];
	CGFloat height = [(NSString *)[params objectForKey:@"adHeight"] floatValue];
    
    _adView = [[MRAdView alloc] initWithFrame:CGRectMake(0, 0, width, height) 
                              allowsExpansion:YES
                             closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                placementType:MRAdViewPlacementTypeInline];
    _adView.delegate = self;
    [_adView loadCreativeWithHTMLString:payloadString 
                                baseURL:nil];
    
    [payloadString release];
}

- (void)dealloc {
    _adView.delegate = nil;
    [_adView release];
    [super dealloc];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation {
    [_adView rotateToOrientation:newOrientation];
}

- (void)closeButtonPressed {
    
}

#pragma mark -
#pragma mark MRAdViewControllerDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adDidLoad:(MRAdView *)adView {
    [self.delegate adapter:self didFinishLoadingAd:adView shouldTrackImpression:YES];
}

- (void)adDidFailToLoad:(MRAdView *)adView {
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)appShouldSuspendForAd:(MRAdView *)adView {
    [self.delegate pauseAutorefresh];
    [self.delegate userActionWillBeginForAdapter:self];
}

- (void)appShouldResumeFromAd:(MRAdView *)adView {
    [self.delegate userActionDidFinishForAdapter:self];
    [self.delegate resumeAutorefreshIfEnabled];
}

@end
