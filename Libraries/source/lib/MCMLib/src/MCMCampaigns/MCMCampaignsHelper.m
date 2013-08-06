//
//  MCMCampaignsHelper.m
//  MalcomDemoApp
//
//  Created by Pedro Durán on 29/05/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import "MCMCampaignsHelper.h"
#import "MCMCoreAPIRequest.h"
#import "MCMCoreManager.h"
#import "MCMCore.h"
#import "MCMCampaignBannerViewController.h"
#import "MCMCampaignsDefines.h"

@interface MCMCampaignsHelper ()

/**
 Method that gets randomly weighted a campaign to serve.
 @param NSArray campaigs that only one will be selected based on their weight.
 @return MCMCampaignModel campaign selected.
 @since 2.0.0
 */
+ (MCMCampaignDTO *)getCampaignPerWeight:(NSArray *)campaigns;

@end

@implementation MCMCampaignsHelper

+ (void)notifyServer:(NSString *)action andCampaign:(MCMCampaignDTO *)campaign{
    
    //url
    NSString *path = [NSString stringWithFormat:MCMCAMPAIGN_HIT_URL,
                      [campaign campaignId],
                      action,
                      [[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyMalcomAppId],
                      [MCMCoreUtils uniqueIdentifier]];
    IF_IOS7_OR_GREATER(
                       path = [NSString stringWithFormat:MCMCAMPAIGN_HIT_URL_IOS7,
                               [campaign campaignId],
                               action,
                               [[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyMalcomAppId],
                               [MCMCoreUtils deviceIdentifier]];
    )
    
    NSString *urlString = [[MCMCoreManager sharedInstance] malcomUrlForPath:path];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    //request
    MCMCoreAPIRequest *request = [[MCMCoreAPIRequest alloc] initWithURL:url];
    
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"type", @"campaingHit",nil]];
    [request startSynchronous];
    
    
    NSError *error = [request error];
    
    if ((error) || ([request responseStatusCode]>=400)) {
        MCMLog(@" Error sending: %@", [request responseStatusMessage]);
    }
    
}

+ (MCMCampaignDTO *)selectCampaign:(NSArray *)campaigns forType:(CampaignType)type{
    //Get the sources for the current CampaignType
    MCMCampaignDTO *selectedCampaign = nil;
    if (type == IN_APP_CROSS_SELLING || type == IN_APP_PROMOTION) {
        //Gets the one that fits better depending on the weight of the campaign
        NSArray *filteredCampaigns = [MCMCampaignsHelper getCampaignsArray:campaigns forType:type];
        //Should have at least one campaign
        if ([filteredCampaigns count] > 0) {
            selectedCampaign = [MCMCampaignsHelper getCampaignPerWeight:filteredCampaigns];
        }
    }
    
    return [selectedCampaign autorelease];
}

+ (NSArray *)createBannersForCampaigns:(NSArray *)campaigns inView:(UIView *)containerView{
    //Get the sources for the current CampaignType
    NSMutableArray *bannersArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    for (int i=0;i<[campaigns count];i++) {
        //creates a banner with the specifications
        MCMCampaignBannerViewController *bannerViewController = [[MCMCampaignBannerViewController alloc] initInView:containerView andCampaign:[campaigns objectAtIndex:i]];
        [bannerViewController.view setTag:i];
        
        [bannersArray addObject:bannerViewController];
    }
    
    return [NSArray arrayWithArray:bannersArray];
}

+ (NSMutableArray *)getCampaignsArray:(NSArray *)campaigns forType:(CampaignType)type{
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    //generates the array with only the promotion campaigns
    for(int i=0; i<[campaigns count]; i++){
        
        MCMCampaignDTO *campaignModel = [campaigns objectAtIndex:i];
        
        if (campaignModel.type == type) {
            [resultArray addObject:campaignModel];
        }
        
    }
    
    return [resultArray autorelease];
    
}

+ (void)showRateMyAppAlert:(MCMCampaignDTO *)campaign onCompletion:(void (^)(bool userRatem, bool userDisableRate))completion{
    
}

#pragma mark - Private methods

+ (MCMCampaignDTO *)getCampaignPerWeight:(NSArray *)campaigns{
    
    
    NSMutableArray *weightedArray = [[NSMutableArray alloc] init];
    
    //generates the array to random weighted selection
    for(int i=0; i<[campaigns count]; i++){
        
        MCMCampaignDTO *campaignModel = [campaigns objectAtIndex:i];
        
        //Only process the campaign if it has media file related
        if (campaignModel.media != nil && ![campaignModel.media isEqualToString:@""]){
            
            //adds to the weighted array as ids as weight has
            for(int j=0; j<campaignModel.weight;j++){
                [weightedArray addObject:[NSNumber numberWithInt:i]];
            }
            
        }
        
    }
    
    //generates random number
    int selection = arc4random()%[weightedArray count];
    
    //gets the random position and gets the id written on it. It will be one of the campaigns
    MCMCampaignDTO *selectedCampaignModel = [campaigns objectAtIndex:[[weightedArray objectAtIndex:selection] intValue]];
    [weightedArray release];
    
    return selectedCampaignModel;
    
}


@end
