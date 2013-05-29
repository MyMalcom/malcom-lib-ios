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
 @return MCMCampaignModel campaign selected.
 @since 2.0.0
 */
+ (MCMCampaignModel *)getCampaignPerWeight:(NSArray *)campaigns;

/**
 Method that gets the promotion campaigns from multitype campaigns array
 @return NSArray with all promotion campaigns.
 @since 2.0.1
 */
+ (NSMutableArray *)getPromotionCampaignsArray:(NSArray *)campaigns;

@end

@implementation MCMCampaignsHelper

+ (void)notifyServer:(NSString *)action andCampaign:(MCMCampaignModel *)campaign{
    
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
    
    if ((error) || ([request responseStatusCode]<402)) {
        [MCMLog log:[NSString stringWithFormat:@"Malcom Campaign - MCMCampaignManager Error sending: %@", [request responseStatusMessage]]
             inLine:__LINE__
         fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    }
    
}

+ (NSArray *)filterCampaigns:(NSArray *)campaigns forType:(CampaignType)type{
    //Get the sources for the current CampaignType
    NSArray *selectionCampaignsArray;
    if (type == IN_APP_CROSS_SELLING) {
        //gets the one that fits better depending on the weight of the campaign
        selectionCampaignsArray = [[[NSArray alloc] initWithObjects:[MCMCampaignsHelper getCampaignPerWeight:campaigns], nil] retain];
    } else if (type == IN_APP_PROMOTION) {
        selectionCampaignsArray = [[MCMCampaignsHelper getPromotionCampaignsArray:campaigns] retain];
    } else {
        selectionCampaignsArray = [[NSArray alloc] init];
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

+ (MCMCampaignModel *)getCampaignPerWeight:(NSArray *)campaigns{
    
    
    NSMutableArray *weightedArray = [[NSMutableArray alloc] init];
    
    //generates the array to random weighted selection
    for(int i=0; i<[campaigns count]; i++){
        
        MCMCampaignModel *campaignModel = [campaigns objectAtIndex:i];
        
        //adds to the weighted array as ids as weight has
        for(int j=0; j<campaignModel.weight;j++){
            [weightedArray addObject:[NSNumber numberWithInt:i]];
        }
        
    }
    
    //generates random number
    int selection = arc4random()%[weightedArray count];
    
    //gets the random position and gets the id written on it. It will be one of the campaigns
    MCMCampaignModel *selectedCampaignModel = [campaigns objectAtIndex:[[weightedArray objectAtIndex:selection] intValue]];
    [weightedArray release];
    
    return selectedCampaignModel;
    
}


+ (NSMutableArray *)getPromotionCampaignsArray:(NSArray *)campaigns{
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    //generates the array with only the promotion campaigns
    for(int i=0; i<[campaigns count]; i++){
        
        MCMCampaignModel *campaignModel = [campaigns objectAtIndex:i];
        
        if (campaignModel.type == IN_APP_PROMOTION) {
            [resultArray addObject:campaignModel];
        }
        
    }
    
    return [resultArray autorelease];
    
}


@end
