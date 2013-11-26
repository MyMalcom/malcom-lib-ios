//
//  MCMCampaignModel.h
//  MalcomLib
//
//  Created by Manuel de la Mata Sáez on 21/02/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _CampaignType {
	IN_APP_PROMOTION = 0,
	IN_APP_RATE_MY_APP = 1,
	IN_APP_CROSS_SELLING = 2,
	IN_APP_EXTERNAL_URL = 3
} CampaignType;

typedef enum _CampaignPosition {
    TOP = 0,
    BOTTOM = 1,
    MIDDLE_LANDSCAPE = 2,
    MIDDLE_PORTRAIT = 3,
    FULL_SCREEN = 4
} CampaignPosition;

@interface MCMCampaignDTO : NSObject

@property (nonatomic,retain) NSString *campaignId;          //campaign id
@property (nonatomic,retain) NSString *name;                //campaign name
@property (nonatomic,retain) NSString *start;               //campaign start date
@property (nonatomic,retain) NSString *end;                 //campaign end date
@property (nonatomic,retain) NSString *createdOn;           //campaign creation date
@property (nonatomic,retain) NSString *campaignDescription; //campaign description field
@property (nonatomic,assign) CampaignType type;             //type of campaign: cross-selling, etc
@property (nonatomic,retain) NSString *media;               //image of the banner or campaign to show
@property (nonatomic,assign) CampaignPosition position;     //position in screen
@property (nonatomic,retain) NSString *promotionType;       //the type of the object promotion
@property (nonatomic,retain) NSString *promotionIdentifier; //app store identifier
@property (nonatomic,retain) NSURL *externalPromotionURL;	//external promotion url
@property (nonatomic,retain) NSDictionary *clientLimitFeature;//the client limit parameters
@property (nonatomic,copy) NSDictionary *customParams;		//Custom parameters defined in malcom
@property (nonatomic,assign) int weight;					//this value is used to random weighted selection once the total weight is known

- (id)initWithDictionary:(NSDictionary *)dict;
- (void)hydrate:(NSDictionary *)data;

/**
 Check if the campaign banner should be shown on full screen
 @since 2.0
 */
- (BOOL)showOnWindow;

/**
 Return the parameters defined on malcom
 @since 2.0.1
 */
- (NSObject *)getCustomParam:(NSString *)key;

@end

