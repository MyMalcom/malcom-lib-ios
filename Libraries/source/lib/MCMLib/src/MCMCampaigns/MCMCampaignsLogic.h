//
//  MCMCampaignsLogic.h
//  MalcomDemoApp
//
//  Created by Pedro Durán on 02/08/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMCampaignDTO.h"

@interface MCMCampaignsLogic : NSObject

+ (BOOL)shouldShowAlert:(MCMCampaignDTO *)campaign;

+ (void)updateRateAlertSession:(MCMCampaignDTO *)campaign;

+ (void)updateRateAlertDate;

+ (void)updateRateAlertDontShowAgain;

@end
