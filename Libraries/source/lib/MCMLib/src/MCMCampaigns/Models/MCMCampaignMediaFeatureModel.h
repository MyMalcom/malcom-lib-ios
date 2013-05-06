//
//  MCMCampaignMediaFeatureModel.h
//  MalcomLib
//
//  Created by Pedro Durán on 25/04/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _CampaignPosition {
    TOP = 0,
    BOTTOM = 1,
    MIDDLE_LANDSCAPE = 2,
    MIDDLE_PORTRAIT = 3,
    FULL_SCREEN = 4
} CampaignPosition;

@interface MCMCampaignMediaFeatureModel : NSObject

@property (nonatomic,retain) NSString *media;               //image of the banner or campaign to show
@property (nonatomic,assign) CampaignPosition position;    //position in screen

- (id)initWithDictionary:(NSDictionary *)dict;
- (void)hydrate:(NSDictionary *)data;

@end
