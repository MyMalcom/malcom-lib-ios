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

+ (NSArray *)filterCampaigns:(NSArray *)campaigns forType:(CampaignType)type;

+ (NSArray *)createBannersForCampaigns:(NSArray *)campaigns inView:(UIView *)containerView;

@end
