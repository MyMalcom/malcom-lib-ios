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

/**
 Method that gets the campaigns with the selected type from multitype campaigns array.
 @param campaigns that will be filtered to get only the selected type.
 @return NSArray with the selected type campaigns.
 @since 2.0.1
 */
+ (NSMutableArray *)getCampaignsArray:(NSArray *)campaigns forType:(CampaignType)type;

@end

@implementation MCMCampaignsHelper

+ (void)notifyServer:(NSString *)action andCampaign:(MCMCampaignDTO *)campaign{
    
    //url
    NSString *path = [NSString stringWithFormat:MCMCAMPAIGN_HIT_URL,
                      [campaign campaignId],
                      action,
                      [[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyMalcomAppId],
                      [MCMCoreUtils uniqueIdentifier]];
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

+ (NSArray *)filterCampaigns:(NSArray *)campaigns forType:(CampaignType)type{
    //Get the sources for the current CampaignType
    NSArray *selectionCampaignsArray = [[NSArray alloc] init];
    if (type == IN_APP_CROSS_SELLING) {
        //Gets the one that fits better depending on the weight of the campaign
        NSArray *crossSellingCampaigns = [MCMCampaignsHelper getCampaignsArray:campaigns forType:IN_APP_CROSS_SELLING];
        //Should have at least one campaign
        if ([crossSellingCampaigns count] > 0) {
            selectionCampaignsArray = [[NSArray alloc] initWithObjects:[MCMCampaignsHelper getCampaignPerWeight:crossSellingCampaigns], nil];
        }
    } else if (type == IN_APP_PROMOTION) {
        selectionCampaignsArray = [[MCMCampaignsHelper getCampaignsArray:campaigns forType:IN_APP_PROMOTION] retain];
    }
    
    return [selectionCampaignsArray autorelease];
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

#pragma mark - Private methods

+ (MCMCampaignDTO *)getCampaignPerWeight:(NSArray *)campaigns{
    
    
    NSMutableArray *weightedArray = [[NSMutableArray alloc] init];
    
    //generates the array to random weighted selection
    for(int i=0; i<[campaigns count]; i++){
        
        MCMCampaignDTO *campaignModel = [campaigns objectAtIndex:i];
        
        //adds to the weighted array as ids as weight has
        for(int j=0; j<campaignModel.weight;j++){
            [weightedArray addObject:[NSNumber numberWithInt:i]];
        }
        
    }
    
    //generates random number
    int selection = arc4random()%[weightedArray count];
    
    //gets the random position and gets the id written on it. It will be one of the campaigns
    MCMCampaignDTO *selectedCampaignModel = [campaigns objectAtIndex:[[weightedArray objectAtIndex:selection] intValue]];
    [weightedArray release];
    
    return selectedCampaignModel;
    
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


@end
