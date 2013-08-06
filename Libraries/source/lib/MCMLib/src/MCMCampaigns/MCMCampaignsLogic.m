//
//  MCMCampaignsLogic.m
//  MalcomDemoApp
//
//  Created by Pedro Durán on 02/08/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import "MCMCampaignsLogic.h"

#define kAttrTimesBeforeRediming @"kAttrTimesBeforeRediming"
#define kAttrDaysUntilPromt @"kAttrDaysUntilPromt"

#define kCampaignId @"kCampaignId"
#define kNotShowAgain @"kNotShowAgain"
#define kSessionsSinceLastAlert @"kSessionsSinceLastAlert"
#define kDateLastDialog @"kDateLastDialog"

@interface MCMCampaignsLogic ()

+ (void)updateRateAlertShowingAgain:(BOOL)showAgain;

+ (void)clearRateMyAppControlParameters;

+ (int)getDaysFromDateInMilliseconds:(long) millisecondsDate;

@end

@implementation MCMCampaignsLogic

+ (BOOL)shouldShowAlert:(MCMCampaignDTO *)campaign {
    //By default should show the dialog
    BOOL shouldShowAlert = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults stringForKey:kCampaignId] isEqualToString:campaign.campaignId]) {
        
        //Promotion limits
        int sessionLimit = [[campaign.clientLimitFeature objectForKey:kAttrTimesBeforeRediming] intValue];
        int daysLimit = [[campaign.clientLimitFeature objectForKey:kAttrDaysUntilPromt] intValue];
        
        //Check the client limits and "notShowAgain"
        int sessionsSinceLastAlert = [defaults integerForKey:kSessionsSinceLastAlert];
        int daysSinceLastAlert = [self getDaysFromDateInMilliseconds:[[defaults objectForKey:kDateLastDialog] longValue]];
        
        BOOL notShowAgain = [defaults boolForKey:kNotShowAgain];
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Update the campaignId on userDefaults
    if (![[defaults stringForKey:kCampaignId] isEqualToString:campaign.campaignId]) {
        [defaults setValue:campaign.campaignId forKey:kCampaignId];
    }
    
    //Update the session number
    if ([defaults objectForKey:kSessionsSinceLastAlert]) {
        [defaults setInteger:([defaults integerForKey:kSessionsSinceLastAlert] + 1) forKey:kSessionsSinceLastAlert];
    } else {
        [defaults setInteger:0 forKey:kSessionsSinceLastAlert];
    }
    
    [defaults synchronize];
    
}

+ (void)updateRateAlertDate {
    [self updateRateAlertShowingAgain:YES];
}

+ (void)updateRateAlertDontShowAgain {
    [self updateRateAlertShowingAgain:NO];
}

#pragma mark - Private methods

+ (void)updateRateAlertShowingAgain:(BOOL)showAgain {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //If it is necesarry show the dialog again, update the control parameters
    if (showAgain) {
        [defaults setObject:[NSNumber numberWithLong:CFAbsoluteTimeGetCurrent()] forKey:kDateLastDialog];
        //Reset the session number
        [defaults setInteger:0 forKey:kSessionsSinceLastAlert];
        
    } else {
        [defaults setBool:YES forKey:kNotShowAgain];
    }
    
    [defaults synchronize];
}

+ (void)clearRateMyAppControlParameters {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:kCampaignId];
    [defaults removeObjectForKey:kNotShowAgain];
    [defaults removeObjectForKey:kSessionsSinceLastAlert];
    [defaults removeObjectForKey:kDateLastDialog];
    
    [defaults synchronize];
    
}

+ (int)getDaysFromDateInMilliseconds:(long)millisecondsDate {
    
    long currentDate = CFAbsoluteTimeGetCurrent();
    
    int days = (int) (currentDate - millisecondsDate) / (24 * 60 * 60 * 1000);
    
    return days;
}

@end
