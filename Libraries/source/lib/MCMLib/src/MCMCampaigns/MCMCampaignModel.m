//
//  MCMCampaignModel.m
//  MalcomLib
//
//  Created by Manuel de la Mata Sáez on 21/02/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import "MCMCampaignModel.h"

@implementation MCMCampaignModel

- (id) initWithDictionary: (NSDictionary*) dict{
    
    self = [super init];
    if(self != nil){
        [self hydrate:dict];
    }
    return self;
}

- (void) hydrate: (NSDictionary*) data{
	
    if( [data objectForKey:@"id"])
		self.campaignId = [data objectForKey:@"id"];
    if( [data objectForKey:@"media"])
		self.media = [data objectForKey:@"media"];
	if( [data objectForKey:@"link"])
		self.urlAppStore = [data objectForKey:@"link"];
	if([data objectForKey:@"type"])
		self.type = [data objectForKey:@"type"];
    if([data objectForKey:@"position"])
		self.position = [data objectForKey:@"position"];
    if([data objectForKey:@"weight"]){
		self.weight = [[data objectForKey:@"weight"] intValue];
    }else{
        self.weight = 1;
    }

}

@end
