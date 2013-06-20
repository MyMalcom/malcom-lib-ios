//
//  MCMCampaignsManagerDelegate.h
//  malcomdemo
//
//  Created by Pedro Durán on 29/04/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMCampaignDTO.h"

@protocol MCMCampaignsManagerDelegate <NSObject>
@optional

- (void)campaignViewWillLoad;
- (void)campaignViewDidLoad;
- (void)campaignViewDidFailRequest:(NSString *)errorMessage;
- (void)campaignViewDidFinish;
- (void)campaignPressed:(MCMCampaignDTO *)campaign;

@end
