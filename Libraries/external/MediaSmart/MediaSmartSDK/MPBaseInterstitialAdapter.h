//
//  MPBaseInterstitialAdapter.h
//  MoPub
//
//  Created by Nafis Jamal on 4/27/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MPInterstitialAdController;

@interface MPBaseInterstitialAdapter : NSObject 
{
	MPInterstitialAdController *_interstitialAdController;
}

@property (nonatomic, readonly) MPInterstitialAdController *interstitialAdController;

/*
 * Creates an adapter with a reference to an MPAdView.
 */
- (id)initWithInterstitialAdController:(MPInterstitialAdController *)interstitialAdController;

/*
 * Sets the adapter's delegate to nil.
 */
- (void)unregisterDelegate;

/*
 * -getAdWithParams: needs to be implemented by adapter subclasses that want to load native ads.
 * -getAd simply calls -getAdWithParams: with a nil dictionary.
 */
- (void)getAd;
- (void)getAdWithParams:(NSDictionary *)params;
- (void)_getAdWithParams:(NSDictionary *)params;

/*
 * Presents the interstitial from the specified view controller.
 */
- (void)showInterstitialFromViewController:(UIViewController *)controller;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPBaseInterstitialAdapterDelegate
@required
/*
 * These callbacks notify you that the adapter (un)successfully loaded an ad.
 */
- (void)adapterDidFinishLoadingAd:(MPBaseInterstitialAdapter *)adapter;
- (void)adapter:(MPBaseInterstitialAdapter *)adapter didFailToLoadAdWithError:(NSError *)error;

/*
 * This callback is triggered when the adapter wants to delegate the actual presentation of an ad,
 * rather than present the ad on its own. The view to be presented is passed as an argument.
 * The implementation of this method should cause the view to be displayed on-screen.
 */
- (void)adapter:(MPBaseInterstitialAdapter *)adapter requestsPresentationForView:(UIView *)content;

/*
 * This callback is triggered when the adapter wishes to dismiss an ad that was previously
 * presented via -adapter:requestsPresentationForView:. The implementation of this method should
 * cause the view to be removed from the screen.
 */
- (void)adapter:(MPBaseInterstitialAdapter *)adapter requestsDismissalOfView:(UIView *)content;

/*
 *
 */
- (void)interstitialWillAppearForAdapter:(MPBaseInterstitialAdapter *)adapter;
- (void)interstitialDidAppearForAdapter:(MPBaseInterstitialAdapter *)adapter;
- (void)interstitialWillDisappearForAdapter:(MPBaseInterstitialAdapter *)adapter;
- (void)interstitialDidDisappearForAdapter:(MPBaseInterstitialAdapter *)adapter;

- (void)interstitialWasTappedForAdapter:(MPBaseInterstitialAdapter *)adapter;
- (void)interstitialDidExpireForAdapter:(MPBaseInterstitialAdapter *)adapter;
@end
