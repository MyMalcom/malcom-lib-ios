//
//  MCMCampaignModel.h
//  MalcomLib
//
//  Created by Manuel de la Mata Sáez on 21/02/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMCampaignModel : NSObject

@property (nonatomic,retain) NSString *campaignId;          //campaign id
@property (nonatomic,retain) NSString *media;               //image of the banner or campaign to show
@property (nonatomic,retain) NSString *urlAppStore;         //appstore url where the campaign is redirected
@property (nonatomic,retain) NSString *type;                //type of campaign: cross-selling, etc
@property (nonatomic,retain) NSString *position;            //position in screen
@property (nonatomic,assign) int weight;                  //this value is used to random weighted selection once the total weight is known

- (id) initWithDictionary: (NSDictionary*) dict;
- (void) hydrate: (NSDictionary*) data;

@end

