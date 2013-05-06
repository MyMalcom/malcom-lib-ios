//
//  MCMCampaignClientLimitFeatureModel.h
//  MalcomLib
//
//  Created by Pedro Durán on 25/04/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMCampaignClientLimitFeatureModel : NSObject

@property (nonatomic,retain) NSString *clientLimitType;       //the client limit indicator
@property (nonatomic,assign) int limitValue;                  //this value is used to random weighted selection once the total weight is known

- (id)initWithDictionary:(NSDictionary *)dict;
- (void)hydrate:(NSDictionary *)data;

@end
