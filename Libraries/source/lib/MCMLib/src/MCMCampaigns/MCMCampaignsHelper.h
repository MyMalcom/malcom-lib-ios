//
//  MCMCampaignsHelper.h
//  MalcomDemoApp
//
//  Created by Pedro Durán on 29/05/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCMCampaignDTO.h"

@interface MCMCampaignsHelper : NSObject

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

@end
