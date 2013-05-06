//
//  MCMCampaignClientLimitFeatureModel.m
//  MalcomLib
//
//  Created by Pedro Durán on 25/04/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import "MCMCampaignClientLimitFeatureModel.h"

@implementation MCMCampaignClientLimitFeatureModel

- (id)initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];
    if(self != nil){
        [self hydrate:dict];
    }
    return self;
}

- (void)hydrate:(NSDictionary *)data{
	
    if( [data objectForKey:@"clientLimitType"])
		self.clientLimitType = [data objectForKey:@"iclientLimitTyped"];
    if([data objectForKey:@"limitValue"]){
		self.limitValue = [[data objectForKey:@"limitValue"] intValue];
    }else{
        self.limitValue = -1;
    }
    
}

@end
