//
//  MCMIntersitialBannerViewController.h
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 24/01/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "MCMCampaignDTO.h"

@protocol MCMCampaignBannerViewControllerDelegate <NSObject>
@optional

/**
 Method called when the campaign's media is loaded successfully
 @since 2.0.1
 */
- (void)mediaFinishLoading:(MCMCampaignDTO *)campaign;
/**
 Method called when something fails while the campaign's media is loading
 @since 2.0
 */
- (void)mediaFailedLoading:(MCMCampaignDTO *)campaign;
/**
 Method called when the campaign's banner was closed
 @since 2.0
 */
- (void)mediaClosed;
/**
 Method called when the user presses on campaign's banner
 @since 2.0.1
 */
- (void)bannerPressed:(MCMCampaignDTO *)campaign;

@end

@interface MCMCampaignBannerViewController : UIViewController<SKStoreProductViewControllerDelegate>

@property (nonatomic, retain) MCMCampaignDTO *currentCampaignDTO;
@property (nonatomic, retain) UIView *appstoreContainerView;
@property (nonatomic, assign) id <MCMCampaignBannerViewControllerDelegate> delegate;


/**
 Method that initialize the campaign's banner in a view
 @since 2.0
 */
- (id)initInView:(UIView *)view withPlaceholder:(UIImage *)placeHolder andCampaign:(MCMCampaignDTO*)campaign;

/**
 Method that shows the cross campaign banner with animation
 @since 2.0.1
 */
- (void)showCampaignBannerAnimated;

/**
 Method to know if the bannerView should be present on full screen
 */
- (BOOL)needsToDisplayOnWindow;

@end
