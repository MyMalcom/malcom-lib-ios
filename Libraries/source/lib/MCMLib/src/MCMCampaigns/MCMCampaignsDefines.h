//
//  MCMCampaignsDefines.h
//  MalcomDemoApp
//
//  Created by Pedro Durán on 29/05/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MCMCAMPAIGN_URL @"v2/campaigns/application/%@/udid/%@"
#define MCMCAMPAIGN_HIT_URL @"v2/campaigns/%@/hit/%@/application/%@/udid/%@"

//IOS6+
#define MCMCAMPAIGN_URL_IOS6 @"v2/campaigns/application/%@/identifier/%@"
#define MCMCAMPAIGN_HIT_URL_IOS6 @"v2/campaigns/%@/hit/%@/application/%@/identifier/%@"

#define CURRENT_CAMPAIGN_VIEW_TAG 100
#define DEFAULT_DURATION 15
