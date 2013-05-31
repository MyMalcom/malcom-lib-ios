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
- (void)mediaFinishLoading:(MCMCampaignDTO *)campaign;
- (void)mediaFailedLoading;
- (void)mediaClosed;
- (void)bannerPressed:(MCMCampaignDTO *)campaign;
@end

@interface MCMCampaignBannerViewController : UIViewController<SKStoreProductViewControllerDelegate>

@property (nonatomic, retain) MCMCampaignDTO *currentCampaignModel;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UIView *appstoreContainerView;
@property (nonatomic, retain) UIView *backgroundFadedView;      //faded view for middle banners
@property (nonatomic, retain) UIButton *closeButton;            //button to close the campaign
@property (nonatomic, retain) UIButton *bannerButton;           //button with campaign
@property (nonatomic,getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

@property (nonatomic, retain) NSMutableData *dataMedia;
@property (nonatomic, retain) NSURLConnection *connection;

@property (nonatomic, assign) id <MCMCampaignBannerViewControllerDelegate> delegate;

- (id)initInView:(UIView *)view andCampaign:(MCMCampaignDTO*)campaign;
- (BOOL)needsToDisplayOnWindow;

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled;
@end
