//
//  MCMCampaignMediaFeatureModel.m
//  MalcomLib
//
//  Created by Pedro Durán on 25/04/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import "MCMCampaignMediaFeatureModel.h"

#define kPositionTOP @"TOP"
#define kPositionBOTTOM @"BOTTOM"
#define kPositionMIDDLE_LANDSCAPE @"TOP"
#define kPositionMIDDLE_PORTRAIT @"MIDDLE_PORTRAIT"
#define kPositionFULL_SCREEN @"FULL_SCREEN"

@implementation MCMCampaignMediaFeatureModel

- (id)initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];
    if(self != nil){
        [self hydrate:dict];
    }
    return self;
}

- (void)hydrate:(NSDictionary *)data{
	
    if( [data objectForKey:@"media"])
		self.media = [data objectForKey:@"media"];
    if([data objectForKey:@"position"]){
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

@end
