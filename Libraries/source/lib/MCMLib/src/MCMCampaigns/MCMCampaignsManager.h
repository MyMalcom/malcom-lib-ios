//
//  MCMCampaignsManager.h
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 25/01/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "MCMCampaignsManagerDelegate.h"
#import "MCMCampaignDTO.h"

@interface MCMCampaignsManager : NSObject <SKStoreProductViewControllerDelegate>

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
- (void)addBannerType:(CampaignType)type inView:(UIView*)view andPlaceHolder:(UIImage *)placeHolder;

/**
 Method that starts the manager and requests a banner to server.
 @param view View where is going to be placed the banner.
 @param appstoreView View where is going to be placed the appstoreView storekit.
 @since 2.0.0
 */
- (void)addBannerType:(CampaignType)type inView:(UIView*)view withAppstoreView:(UIView*)appstoreView andPlaceHolder:(UIImage *)placeHolder;


/**
 Method that removes the current banner.
 @since 2.0.0
 */
- (void)removeCurrentBanner;

/**
 Method that request the available campaigns from server, filters them and executes the completion block with the result
 @param type the campaign type to filter the server response
 @param ^completion block that will be executed with the filtered response
 @param ^error block that will be executed when an error occurs
 */
- (void)requestBannersType:(CampaignType)type
           withPlaceHolder:(UIImage *)placeHolder
                completion:(void (^)(NSArray * campaignBannersVC))completion error:(void (^)(NSString *errorMessage))error;

@end
