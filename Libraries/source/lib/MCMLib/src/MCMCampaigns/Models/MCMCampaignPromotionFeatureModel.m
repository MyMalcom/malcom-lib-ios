//
//  MCMCampaignPromotionFeatureModel.m
//  MalcomLib
//
//  Created by Pedro Durán on 25/04/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import "MCMCampaignPromotionFeatureModel.h"

@implementation MCMCampaignPromotionFeatureModel

- (id)initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];
    if(self != nil){
        [self hydrate:dict];
    }
    return self;
}

- (void)hydrate:(NSDictionary *)data{
	
    if( [data objectForKey:@"promotionType"])
		self.promotionType = [data objectForKey:@"promotionType"];
    if([data objectForKey:@"promotionIdentifier"])
        self.promotionIdentifier = [data objectForKey:@"promotionIdentifier"];
}

@end
