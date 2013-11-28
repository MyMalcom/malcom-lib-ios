//
//  MCMCampaignsHelper.h
//  MalcomDemoApp
//
//  Created by Pedro Durán on 29/05/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "MCMCampaignDTO.h"

#define kCampaignImpressionHit @"IMPRESSION"
#define kCampaignClickHit @"CLICK"
#define KCampaignRateHit @"RATE"
#define kCampaignRemindHit @"REMIND_LATER"
#define kCampaignNeverRateHit @"NEVER_RATE"

@interface MCMCampaignsHelper : NSObject <UIAlertViewDelegate>

+ (void)notifyServer:(NSString *)action andCampaign:(MCMCampaignDTO *)campaign;

+ (MCMCampaignDTO *)selectCampaign:(NSArray *)campaigns forType:(CampaignType)type;

+ (NSArray *)createBannersForCampaigns:(NSArray *)campaigns inView:(UIView *)containerView withPlaceHolder:(UIImage *)placeHolderImage;

/**
 Method that gets the campaigns with the selected type from multitype campaigns array.
 @param campaigns that will be filtered to get only the selected type.
 @return NSArray with the selected type campaigns.
 @since 2.0.1
 */
+ (NSMutableArray *)getCampaignsArray:(NSArray *)campaigns forType:(CampaignType)type;

- (void)showRateMyAppAlert:(MCMCampaignDTO *)campaign onCompletion:(void (^)(bool userRate, bool userDisableRate))completion;

+ (void)openAppStoreWithAppId:(NSString *)appId withDelegate:(id<SKStoreProductViewControllerDelegate>)delegate andAppStoreContainerView:(UIView *)appStoreContainerView;

+ (void)openExternalCampaign:(MCMCampaignDTO *)campaign;

@end
