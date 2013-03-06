//
//  MCMIntersitialBannerViewController.h
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 24/01/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "MCMCampaignModel.h"

@interface MCMIntersitialBannerViewController : UIViewController<SKStoreProductViewControllerDelegate>

@property (nonatomic, retain) MCMCampaignModel *currentCampaignModel;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UIView *appstoreContainerView;

- (id)initInView:(UIView *)view andCampaign:(MCMCampaignModel*)campaign;
- (BOOL)needsToDisplayOnWindow;

@end
