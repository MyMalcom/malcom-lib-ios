//
//  MCMCampaignModel.h
//  MalcomLib
//
//  Created by Manuel de la Mata Sáez on 21/02/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMCampaignMediaFeatureModel.h"
#import "MCMCampaignPromotionFeatureModel.h"
#import "MCMCampaignClientLimitFeatureModel.h"

typedef enum _CampaignType {
	IN_APP_PROMOTION = 0,
	IN_APP_RATE_MY_APP = 1,
	IN_APP_CROSS_SELLING = 2
} CampaignType;

@interface MCMCampaignModel : NSObject

@property (nonatomic,retain) NSString *campaignId;          //campaign id
@property (nonatomic,retain) NSString *name;                //campaign name
@property (nonatomic,retain) NSString *start;               //campaign start date
@property (nonatomic,retain) NSString *end;                 //campaign end date
@property (nonatomic,retain) NSString *createdOn;           //campaign creation date
@property (nonatomic,assign) CampaignType type;            //type of campaign: cross-selling, etc
@property (nonatomic,retain) MCMCampaignMediaFeatureModel *mediaFeature;
@property (nonatomic,retain) MCMCampaignPromotionFeatureModel *promotionFeature;
@property (nonatomic,retain) MCMCampaignClientLimitFeatureModel *clientLimitFeature;
@property (nonatomic,assign) int weight;                  //this value is used to random weighted selection once the total weight is known

- (id)initWithDictionary:(NSDictionary *)dict;
- (void)hydrate:(NSDictionary *)data;
/**
 Check if the campaign banner should be shown on full screen
 @since 2.0
 */
- (BOOL)showOnWindow;

@end

