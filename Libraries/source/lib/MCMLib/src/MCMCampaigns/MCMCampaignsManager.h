//
//  MCMCampaignsManager.h
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 25/01/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MCMCampaignsManagerDelegate.h"
#import "MCMCampaignModel.h"

@interface MCMCampaignsManager : NSObject

@property (nonatomic, assign) int duration;                                 //campaign duration
@property (nonatomic, assign) id<MCMCampaignsManagerDelegate> delegate;     //campaigns delegate

/**
 Gets the singleton instance for this class
 @returns Singleton object for the class
 @since 1.0
 */
+ (MCMCampaignsManager *)sharedInstance;


/**
 Method that starts the manager and requests a banner to server.
 @param view View where is going to be placed the banner.
 @since 2.0.0
 */
- (void)addBannerType:(CampaignType)type inView:(UIView*)view;

/**
 Method that starts the manager and requests a banner to server.
 @param view View where is going to be placed the banner.
 @param appstoreView View where is going to be placed the appstoreView storekit.
 @since 2.0.0
 */
- (void)addBannerType:(CampaignType)type inView:(UIView*)view withAppstoreView:(UIView*)appstoreView;


/**
 Method that removes the current banner.
 @since 2.0.0
 */
- (void)removeCurrentBanner;


@end
