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

@implementation MCMCampaignModel

- (id)initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];
    if(self != nil){
        [self hydrate:dict];
    }
    return self;
}

- (void)hydrate:(NSDictionary *)data{
	
    if( [data objectForKey:@"id"])
		self.campaignId = [data objectForKey:@"id"];
    if( [data objectForKey:@"name"])
		self.name = [data objectForKey:@"name"];
    if( [data objectForKey:@"start"])
		self.start = [data objectForKey:@"start"];
    if( [data objectForKey:@"end"])
		self.end = [data objectForKey:@"end"];
    if( [data objectForKey:@"createdOn"])
		self.createdOn = [data objectForKey:@"createdOn"];
    if([data objectForKey:@"type"]){
        NSString *dataType = [data objectForKey:@"type"];
        if ([dataType isEqualToString:kTypeIN_APP_PROMOTION]) {
            self.type = IN_APP_PROMOTION;
        } else if ([dataType isEqualToString:kTypeIN_APP_RATE_MY_APP]){
            self.type = IN_APP_RATE_MY_APP;
        } else if ([dataType isEqualToString:kTypeIN_APP_CROSS_SELLING]) {
            self.type = IN_APP_CROSS_SELLING;
        }
    }
    if([data objectForKey:@"mediaFeature"]){
        self.mediaFeature = [[MCMCampaignMediaFeatureModel alloc] initWithDictionary:[data objectForKey:@"mediaFeature"]];
    }
    if([data objectForKey:@"promotionFeature"]){
        self.promotionFeature = [[MCMCampaignPromotionFeatureModel alloc] initWithDictionary:[data objectForKey:@"promotionFeature"]];
    }
    if([data objectForKey:@"clientLimitFeature"]){
        self.clientLimitFeature = [[MCMCampaignClientLimitFeatureModel alloc] initWithDictionary:[data objectForKey:@"clientLimitFeature"]];
    }
    if([data objectForKey:@"customParamsFeature"] && [[data objectForKey:@"customParamsFeature"] objectForKey:@"properties"]){
        self.customParams = [[data objectForKey:@"customParamsFeature"] objectForKey:@"properties"];
    }
    if([data objectForKey:@"serverOrderFeature"]){
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
    
    if (self.mediaFeature!=nil) {
        CampaignPosition campPosition = self.mediaFeature.position;
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

@end
