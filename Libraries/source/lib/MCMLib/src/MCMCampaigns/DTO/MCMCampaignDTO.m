//
//  MCMCampaignModel.m
//  MalcomLib
//
//  Created by Manuel de la Mata Sáez on 21/02/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import "MCMCampaignDTO.h"

#define kTypeIN_APP_PROMOTION @"IN_APP_PROMOTION"
#define kTypeIN_APP_RATE_MY_APP @"IN_APP_RATE_MY_APP"
#define kTypeIN_APP_CROSS_SELLING @"IN_APP_CROSS_SELLING"
#define kTypeIN_APP_EXTERNAL_URL @"IN_APP_EXTERNAL_URL"

#define kPositionTOP @"TOP"
#define kPositionBOTTOM @"BOTTOM"
#define kPositionMIDDLE_LANDSCAPE @"MIDDLE_LANDSCAPE"
#define kPositionMIDDLE_PORTRAIT @"MIDDLE_PORTRAIT"
#define kPositionFULL_SCREEN @"FULL_SCREEN"

@interface MCMCampaignDTO()

- (void)hydrateMediaFeature:(NSDictionary *)data;
- (void)hydratePromotionFeature:(NSDictionary *)data;
- (void)hydrateClientLimitFeature:(NSDictionary *)data;

@end

@implementation MCMCampaignDTO

- (id)initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];
    if (self != nil){
        [self hydrate:dict];
    }
    return self;
}

- (void)hydrate:(NSDictionary *)data{
	
    if ([data objectForKey:@"id"])
		self.campaignId = [[data objectForKey:@"id"] stringValue];
    if ([data objectForKey:@"name"])
		self.name = [data objectForKey:@"name"];
    if ([data objectForKey:@"start"])
		self.start = [data objectForKey:@"start"];
    if ([data objectForKey:@"end"])
		self.end = [data objectForKey:@"end"];
    if ([data objectForKey:@"createdOn"])
		self.createdOn = [data objectForKey:@"createdOn"];
    if ([data objectForKey:@"descriptionFeature"] && [[data objectForKey:@"descriptionFeature"] objectForKey:@"promotionDescription"])
        self.campaignDescription = [[data objectForKey:@"descriptionFeature"] objectForKey:@"promotionDescription"];    
    if ([data objectForKey:@"type"]){
        NSString *dataType = [data objectForKey:@"type"];
        if ([dataType isEqualToString:kTypeIN_APP_PROMOTION]) {
            self.type = IN_APP_PROMOTION;
        } else if ([dataType isEqualToString:kTypeIN_APP_RATE_MY_APP]){
            self.type = IN_APP_RATE_MY_APP;
        } else if ([dataType isEqualToString:kTypeIN_APP_CROSS_SELLING]) {
            self.type = IN_APP_CROSS_SELLING;
        } else if ([dataType isEqualToString:kTypeIN_APP_EXTERNAL_URL]) {
            self.type = IN_APP_EXTERNAL_URL;
        }
    }
    
    //Media feature
    if ([data objectForKey:@"mediaFeature"])
        [self hydrateMediaFeature:[data objectForKey:@"mediaFeature"]];
    
	//Promotion feature
    if ([data objectForKey:@"promotionFeature"])
		[self hydratePromotionFeature:[data objectForKey:@"promotionFeature"]];
	
	//External promotion feature
	if ([data objectForKey:@"externalPromotionFeature"]) {
		[self hydrateExternalPromotionFeature:[data objectForKey:@"externalPromotionFeature"]];
	}

    //Client limit feature
    if ([data objectForKey:@"clientLimitFeatures"]){
        [self hydrateClientLimitFeature:[data objectForKey:@"clientLimitFeatures"]];
    }
	
    //Custom params
    if ([data objectForKey:@"customParamsFeature"] && [[data objectForKey:@"customParamsFeature"] objectForKey:@"properties"]){
        self.customParams = [[data objectForKey:@"customParamsFeature"] objectForKey:@"properties"];
    } else {
        //If there is no properties the field doesn't exists
        self.customParams = [[NSDictionary alloc] init];
    }
	
    if ([data objectForKey:@"serverOrderFeature"]){
        if ([[data objectForKey:@"serverOrderFeature"] objectForKey:@"weight"]) {
            self.weight = [[[data objectForKey:@"serverOrderFeature"] objectForKey:@"weight"] intValue];
        } else {
            self.weight = 1;
        }
    }else{
        self.weight = 1;
    }

}

- (BOOL)showOnWindow{
    
    if (self.media!=nil) {
        //in case the type is TOP or BOTTOM it will be shown in the specified view
        CampaignPosition campPosition = self.position;
        return (campPosition == FULL_SCREEN) || (campPosition == MIDDLE_LANDSCAPE) || (campPosition == MIDDLE_PORTRAIT);
    } else {
        return NO;
    }
}

- (NSObject *)getCustomParam:(NSString *)key {
    return [self.customParams objectForKey:key];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"Campaign: %@", self.name];
}

#pragma mark - Private methods

- (void)hydrateMediaFeature:(NSDictionary *)data{
	
    if ([data objectForKey:@"media"])
		self.media = [data objectForKey:@"media"];
    if ([data objectForKey:@"position"]){
        NSString *dataPosition = [data objectForKey:@"position"];
        if ([dataPosition isEqualToString:kPositionTOP]) {
            self.position = TOP;
        } else if ([dataPosition isEqualToString:kPositionBOTTOM]){
            self.position = BOTTOM;
        } else if ([dataPosition isEqualToString:kPositionMIDDLE_LANDSCAPE]) {
            self.position = MIDDLE_LANDSCAPE;
        } else if ([dataPosition isEqualToString:kPositionMIDDLE_PORTRAIT]) {
            self.position = MIDDLE_PORTRAIT;
        } else if ([dataPosition isEqualToString:kPositionFULL_SCREEN]) {
            self.position = FULL_SCREEN;
        } else {
            self.position = TOP;
        }
    }
}

- (void)hydratePromotionFeature:(NSDictionary *)data{
	
    if ([data objectForKey:@"promotionType"])
		self.promotionType = [data objectForKey:@"promotionType"];
    if ([data objectForKey:@"promotionIdentifier"])
		self.promotionIdentifier = [data objectForKey:@"promotionIdentifier"];
    
}

- (void)hydrateExternalPromotionFeature:(NSDictionary *)data{
	
    if ([data objectForKey:@"externalUrl"]) {
		NSString *urlString = [data objectForKey:@"externalUrl"];
		NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		self.externalPromotionURL = url;
	}
}

- (void)hydrateClientLimitFeature:(NSArray *)data{
    
    self.clientLimitFeature = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *dict in data) {
        NSString *clientLimit = [dict objectForKey:@"limitValue"];
        NSString *limitType = [dict objectForKey:@"clientLimitType"];
        [self.clientLimitFeature setValue:clientLimit forKey:limitType];
    }
    
}

@end
