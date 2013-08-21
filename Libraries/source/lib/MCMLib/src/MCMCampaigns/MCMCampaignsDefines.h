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

//IOS7+
#define MCMCAMPAIGN_URL_IOS7 @"v2/campaigns/application/%@/identifier/%@"
#define MCMCAMPAIGN_HIT_URL_IOS7 @"v2/campaigns/%@/hit/%@/application/%@/identifier/%@"

#define CURRENT_CAMPAIGN_VIEW_TAG 100
#define DEFAULT_DURATION 15

// AppStoreURL
#define ITUNES_URL @"https://itunes.apple.com/es/app/id%@"

// RateMyApp Alert
#define RATE_TITLE_LOC @"_Malcom_rate_title"
#define RATE_MESSAGE_LOC @"_Malcom_rate_message"
#define RATE_BUTTON_LOC @"_Malcom_rate_button"
#define RATE_REMIND_LOC @"_Malcom_remind_button"
#define RATE_DISABLE_LOC @"_Malcom_disable_button"

#define RATE_TITLE_DEFAULT @"Rate My App"
#define RATE_MESSAGE_DEFAULT @"If you enjoy using this app, please take a moment to rate it. Thanks for your support!"
#define RATE_RATE_BUTTON_DEFAULT @"Rate!"
#define RATE_REMIND_BUTTON_DEFAULT @"Remind me later"
#define RATE_DISABLE_BUTTON_DEFAULT @"No, thanks"