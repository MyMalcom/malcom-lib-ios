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

typedef void(^CompletionBlock)(bool userRate, bool userDisableRate);

@interface MCMCampaignsHelper ()

@property (nonatomic, copy) CompletionBlock completionBlock;

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
    if (type == IN_APP_EXTERNAL_URL || type == IN_APP_CROSS_SELLING || type == IN_APP_PROMOTION || type == IN_APP_RATE_MY_APP) {
        //Gets the one that fits better depending on the weight of the campaign
        NSArray *filteredCampaigns = [MCMCampaignsHelper getCampaignsArray:campaigns forType:type];
		if (type == IN_APP_CROSS_SELLING) {
			NSArray *externalURLCampaigns = [MCMCampaignsHelper getCampaignsArray:campaigns forType:IN_APP_EXTERNAL_URL];
			filteredCampaigns = [filteredCampaigns arrayByAddingObjectsFromArray:externalURLCampaigns];
		}
        //Should have at least one campaign
        if ([filteredCampaigns count] > 0) {
            selectedCampaign = [MCMCampaignsHelper getCampaignPerWeight:filteredCampaigns];
        }
    }
    
    return selectedCampaign;
}

+ (NSArray *)createBannersForCampaigns:(NSArray *)campaigns inView:(UIView *)containerView withPlaceHolder:(UIImage *)placeHolderImage{
    //Get the sources for the current CampaignType
    NSMutableArray *bannersArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    for (int i=0;i<[campaigns count];i++) {
        //creates a banner with the specifications
        MCMCampaignBannerViewController *bannerViewController = [[MCMCampaignBannerViewController alloc] initInView:containerView
                                                                                                    withPlaceholder:placeHolderImage
																										andCampaign:[campaigns objectAtIndex:i]];
        [bannerViewController.view setTag:i];
        
        [bannersArray addObject:bannerViewController];
		[bannerViewController release];
    }
    
    return [NSArray arrayWithArray:bannersArray];
}

+ (NSMutableArray *)getCampaignsArray:(NSArray *)campaigns forType:(CampaignType)type{
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    //generates the array with only the promotion campaigns
	
	for (MCMCampaignDTO *campaignModel in campaigns) {
		
		if (campaignModel.type == type) {
            [resultArray addObject:campaignModel];
        }

	}
    
    return [resultArray autorelease];
    
}

- (void)showRateMyAppAlert:(MCMCampaignDTO *)campaign onCompletion:(void (^)(bool userRate, bool userDisableRate))completion{
    
    self.completionBlock = completion;
    
    NSString *title = NSLocalizedString(RATE_TITLE_LOC, @"");
    NSString *message = NSLocalizedString(RATE_MESSAGE_LOC, @"");
    NSString *rateButton = NSLocalizedString(RATE_BUTTON_LOC, @"");
    NSString *remindButton = NSLocalizedString(RATE_REMIND_LOC,@"");
    NSString *disableButton = NSLocalizedString(RATE_DISABLE_LOC,@"");
    
    //If there is no localized string, replace by the default one
    if ([title isEqualToString:RATE_TITLE_LOC]) {
        title = RATE_TITLE_DEFAULT;
    }
    if ([message isEqualToString:RATE_MESSAGE_LOC]) {
        message = RATE_MESSAGE_DEFAULT;
    }
    if ([rateButton isEqualToString:RATE_BUTTON_LOC]) {
        rateButton = RATE_RATE_BUTTON_DEFAULT;
    }
    if ([remindButton isEqualToString:RATE_REMIND_LOC]) {
        remindButton = RATE_REMIND_BUTTON_DEFAULT;
    }
    if ([disableButton isEqualToString:RATE_DISABLE_LOC]) {
        disableButton = RATE_DISABLE_BUTTON_DEFAULT;
    }
    
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:disableButton
                                              otherButtonTitles:rateButton, remindButton, nil];
	
    [alertView show];
}

+ (void)openAppStoreWithAppId:(NSString *)appId withDelegate:(id<SKStoreProductViewControllerDelegate>)delegate andAppStoreContainerView:(UIView *)appStoreContainerView {
    
    if (appId.length > 0) {
        
        if(NSClassFromString(@"SKStoreProductViewController")) { // Checks for iOS 6 feature.
            
            SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
            storeController.delegate = delegate; // productViewControllerDidFinish
            
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * idApple = [f numberFromString:appId];
            [f release];
            NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : idApple };
            
            
            [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
                if (result) {
                    //if it doesnt have where to place the appstoreView it will place it on the VC handler of the banner container view
                    if(!appStoreContainerView){
                        id rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
                        [rootVC presentViewController:storeController animated:YES completion:nil];
                    }else{ //if it is specified, it will be placed on the appstoreContainerView
                        [(UIViewController *)[appStoreContainerView nextResponder] presentViewController:storeController animated:YES completion:nil];
                        
                    }
                    
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"There was a problem displaying the app" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                }
            }];
            
            
        } else { // Before iOS 6, we can only open the URL
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:ITUNES_URL, appId]]];
            
        }
    } else {
        MCMLog(@"The campaign has no app identifier to show on appstore")
        
        [delegate productViewControllerDidFinish:nil];
    }
}

+ (void)openExternalCampaign:(MCMCampaignDTO *)campaign {
	
	if (campaign.type == IN_APP_EXTERNAL_URL && campaign.externalPromotionURL) {
		[[UIApplication sharedApplication] openURL:campaign.externalPromotionURL];
	}
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
    
    MCMCampaignDTO *selectedCampaignModel = nil;
    
    //If the campaigns have weights, evaluate them
    if ([weightedArray count] > 0) {
        int selection = arc4random()%[weightedArray count];
        
        //gets the random position and gets the id written on it. It will be one of the campaigns
        selectedCampaignModel = [campaigns objectAtIndex:[[weightedArray objectAtIndex:selection] intValue]];
        
    } else {
        //By default select the first campaign
        selectedCampaignModel = [campaigns objectAtIndex:0];
        
    }
        
    [weightedArray release];
    
    return selectedCampaignModel;
    
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:{
            //Disable button Pressed
            self.completionBlock(NO,YES);
            break;
        }
        case 1:{
            //Rate button pressed
            self.completionBlock(YES,NO);
            break;
        }
        case 2:{
            //RemindMeLater button pressed
            self.completionBlock(NO,NO);
            break;
        }
    }
}

@end
