//
//  MCMCampaignPromotionFeatureModel.h
//  MalcomLib
//
//  Created by Pedro Durán on 25/04/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMCampaignPromotionFeatureModel : NSObject

@property (nonatomic,retain) NSString *promotionType;       //campaign id
@property (nonatomic,retain) NSString *promotionIdentifier; //app store identifier

- (id)initWithDictionary:(NSDictionary*)dict;
- (void)hydrate:(NSDictionary *)data;

@end
