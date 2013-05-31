//
//  MCMCampaignModel.m
//  MalcomLib
//
//  Created by Manuel de la Mata Sáez on 21/02/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import "MCMCampaignModel.h"

#define kTypeIN_APP_PROMOTION @"IN_APP_PROMOTION"
#define kTypeIN_APP_RATE_MY_APP @"IN_APP_RATE_MY_APP"
#define kTypeIN_APP_CROSS_SELLING @"IN_APP_CROSS_SELLING"

#define kPositionTOP @"TOP"
#define kPositionBOTTOM @"BOTTOM"
#define kPositionMIDDLE_LANDSCAPE @"TOP"
#define kPositionMIDDLE_PORTRAIT @"MIDDLE_PORTRAIT"
#define kPositionFULL_SCREEN @"FULL_SCREEN"

@interface MCMCampaignModel()

- (void)hydrateMediaFeature:(NSDictionary *)data;
- (void)hydratePromotionFeature:(NSDictionary *)data;
- (void)hydrateClientLimitFeature:(NSDictionary *)data;

@end

@implementation MCMCampaignModel

- (id)initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];
    if (self != nil){
        [self hydrate:dict];
    }
    return self;
}

- (void)hydrate:(NSDictionary *)data{
	
    if ([data objectForKey:@"id"])
		self.campaignId = [data objectForKey:@"id"];
    if ([data objectForKey:@"name"])
		self.name = [data objectForKey:@"name"];
    if ([data objectForKey:@"start"])
		self.start = [data objectForKey:@"start"];
    if ([data objectForKey:@"end"])
		self.end = [data objectForKey:@"end"];
    if ([data objectForKey:@"createdOn"])
		self.createdOn = [data objectForKey:@"createdOn"];
    if ([data objectForKey:@"type"]){
        NSString *dataType = [data objectForKey:@"type"];
        if ([dataType isEqualToString:kTypeIN_APP_PROMOTION]) {
            self.type = IN_APP_PROMOTION;
        } else if ([dataType isEqualToString:kTypeIN_APP_RATE_MY_APP]){
            self.type = IN_APP_RATE_MY_APP;
        } else if ([dataType isEqualToString:kTypeIN_APP_CROSS_SELLING]) {
            self.type = IN_APP_CROSS_SELLING;
        }
    }
    
    //Media feature
    if ([data objectForKey:@"mediaFeature"])
        [self hydrateMediaFeature:[data objectForKey:@"mediaFeature"]];
    
	//Promotion feature
    if ([data objectForKey:@"promotionFeature"])
		[self hydratePromotionFeature:[data objectForKey:@"promotionType"]];

    //Client limit feature
    if ([data objectForKey:@"clientLimitFeature"]){
        [self hydrateClientLimitFeature:[data objectForKey:@"clientLimitFeature"]];
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
        CampaignPosition campPosition = self.position;
        return (campPosition == FULL_SCREEN) && (campPosition == MIDDLE_LANDSCAPE) && (campPosition == MIDDLE_PORTRAIT);
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
	
    if ([data objectForKey:@"clientLimitType"])
		self.clientLimitType = [data objectForKey:@"iclientLimitTyped"];
    if ([data objectForKey:@"limitValue"]){
		self.limitValue = [[data objectForKey:@"limitValue"] intValue];
    }else{
        self.limitValue = -1;
    }
    
}

- (void)hydrateClientLimitFeature:(NSDictionary *)data{
	
    if ([data objectForKey:@"clientLimitType"])
		self.clientLimitType = [data objectForKey:@"iclientLimitTyped"];
    if ([data objectForKey:@"limitValue"]){
		self.limitValue = [[data objectForKey:@"limitValue"] intValue];
    }else{
        self.limitValue = -1;
    }
    
}

@end
