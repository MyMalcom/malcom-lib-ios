//
//  MCMCampaignsLogic.m
//  MalcomDemoApp
//
//  Created by Pedro Durán on 02/08/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import "MCMCampaignsLogic.h"

#define kAttrTimesBeforeRediming @"TIMES_BEFORE_REMINDING"
#define kAttrDaysUntilPromt @"DAYS_UNTIL_PROMT"


#define kRateMyAppParameters @"kRateMyAppParameters"
#define kCampaignId @"kCampaignId"
#define kNotShowAgain @"kNotShowAgain"
#define kSessionsSinceLastAlert @"kSessionsSinceLastAlert"
#define kDateLastDialog @"kDateLastDialog"

@interface MCMCampaignsLogic ()

+ (void)updateRateAlertShowingAgain:(BOOL)showAgain;

+ (void)clearRateMyAppControlParameters;

+ (NSMutableDictionary *)getRateMyAppParameters;

+ (void)setRateMyAppParameters:(NSDictionary *)parameters;

+ (int)getDaysFromDateInMilliseconds:(long) millisecondsDate;

@end

@implementation MCMCampaignsLogic

+ (BOOL)shouldShowAlert:(MCMCampaignDTO *)campaign {
    //By default should show the dialog
    BOOL shouldShowAlert = YES;
    
    NSMutableDictionary *parameters = [self getRateMyAppParameters];
    
    if ([[parameters objectForKey:kCampaignId] isEqualToString:campaign.campaignId]) {
        
        //Promotion limits
        int sessionLimit = [[campaign.clientLimitFeature objectForKey:kAttrTimesBeforeRediming] intValue];
        int daysLimit = [[campaign.clientLimitFeature objectForKey:kAttrDaysUntilPromt] intValue];
        
        //Check the client limits and "notShowAgain"
        int sessionsSinceLastAlert = [[parameters objectForKey:kSessionsSinceLastAlert] integerValue];
        int daysSinceLastAlert = [self getDaysFromDateInMilliseconds:[[parameters objectForKey:kDateLastDialog] longValue]];
        
        BOOL notShowAgain = [[parameters objectForKey:kNotShowAgain] boolValue];
        BOOL notShouldShowAlert = (sessionsSinceLastAlert < sessionLimit) && (daysSinceLastAlert < daysLimit);
        
        if (notShowAgain || notShouldShowAlert) {
            shouldShowAlert = NO;
        }
        
    } else {
        [self clearRateMyAppControlParameters];
    }
    
    return shouldShowAlert;
}

+ (void)updateRateAlertSession:(MCMCampaignDTO *)campaign {
    
    NSMutableDictionary *parameters = [self getRateMyAppParameters];
    
    //Update the campaignId on userDefaults
    if (![[parameters objectForKey:kCampaignId] isEqualToString:campaign.campaignId]) {
        [parameters setValue:campaign.campaignId forKey:kCampaignId];
    }
    
    //Update the session number
    if ([parameters objectForKey:kSessionsSinceLastAlert]) {
        NSNumber *sessions = [NSNumber numberWithInt:([[parameters objectForKey:kSessionsSinceLastAlert] integerValue] + 1)];
        [parameters setObject:sessions forKey:kSessionsSinceLastAlert];
    } else {
        [parameters setObject:[NSNumber numberWithInt:1] forKey:kSessionsSinceLastAlert];
    }
    
    [self setRateMyAppParameters:parameters];
    
}

+ (void)updateRateAlertDate {
    [self updateRateAlertShowingAgain:YES];
}

+ (void)updateRateAlertDontShowAgain {
    [self updateRateAlertShowingAgain:NO];
}

#pragma mark - Private methods

+ (void)updateRateAlertShowingAgain:(BOOL)showAgain {
    
    NSMutableDictionary *parameters = [self getRateMyAppParameters];
    
    //If it is necesarry show the dialog again, update the control parameters
    if (showAgain) {
        [parameters setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:kDateLastDialog];
        //Reset the session number
        [parameters setObject:[NSNumber numberWithInt:1] forKey:kSessionsSinceLastAlert];
        
    } else {
        [parameters setObject:[NSNumber numberWithBool:YES] forKey:kNotShowAgain];
    }
    
    [self setRateMyAppParameters:parameters];
}

+ (void)clearRateMyAppControlParameters {
    
    [self setRateMyAppParameters:nil];
    
}

+ (NSMutableDictionary *)getRateMyAppParameters {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:kRateMyAppParameters]];
    
    return [parameters autorelease];
}

+ (void)setRateMyAppParameters:(NSDictionary *)parameters {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:parameters forKey:kRateMyAppParameters];
    
    [defaults synchronize];
}

+ (int)getDaysFromDateInMilliseconds:(long)millisecondsDate {
    
    long currentDate = [[NSDate date] timeIntervalSince1970];
    
    int days = (int) (currentDate - millisecondsDate) / (24 * 60 * 60 * 1000);
    
    return days;
}

@end
