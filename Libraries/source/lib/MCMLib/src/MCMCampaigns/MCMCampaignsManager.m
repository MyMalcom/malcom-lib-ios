//
//  MCMCampaignsManager.m
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 25/01/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MCMCampaignsManager.h"
#import "MCMCoreSingleton.h"
#import "MCMASIHTTPRequest.h"
#import "MCMASIDownloadCache.h"
#import "MCMCoreUtils.h"
#import "MCMCoreAPIRequest.h"
#import "MCMCoreManager.h"
#import "MCMCore.h"
#import "MCMCampaignModel.h"
#import "MCMIntersitialBannerViewController.h"
#import "MCMCoreUtils.h"

#define MCMCAMPAIGN_URL @"v2/campaigns/application/%@/udid/%@"
//#define MCMCAMPAIGN_URL @"http://malcom-api-dev.elasticbeanstalk.com/v2/campaigns/application/%@/udid/%@"          //DEV
#define MCMCAMPAIGN_HIT_URL @"v2/campaigns/%@/hit/%@/application/%@/udid/%@"

#define CURRENT_CAMPAIGN_VIEW_TAG 100
#define DEFAULT_DURATION 15

@interface MCMCampaignsManager () <MCMIntersitialBannerViewControllerDelegate>
- (void)requestCampaign;
- (MCMCampaignModel*)getCampaignPerWeight;
- (void)displayCampaign;
- (void)placePromotionBanners:(NSArray *)bannersArray inView:(UIView *)containerView;
- (void)placeCrossSellingBanner:(MCMIntersitialBannerViewController *)bannerViewController inView:(UIView *)containerView;
- (void)appDidBecomeActiveNotification:(NSNotification *)notification;
- (void)hideCampaignView;
- (void)finishCampaignView;
- (void)notifyServer:(NSString *)action andCampaign:(MCMCampaignModel *)campaign;


@property (nonatomic, retain) UIView *campaignContainerView;    //view that contains the banner.
@property (nonatomic, retain) UIView *appstoreContainerView;    //view that contains the appstore.
@property (nonatomic, assign) BOOL campaignsEnabled;            //boolean indicating the campaigns enabling.

@property (nonatomic, retain) NSMutableArray *campaignsArray;
@property (nonatomic, retain) MCMIntersitialBannerViewController *currentIntersitial;
@property (nonatomic, retain) NSTimer *durationTimer;                       //campaign duration
@property (nonatomic, retain) MCMCampaignModel *currentCampaignModel;       //current campaign selected
@property (nonatomic, assign) CampaignType type;            //type of campaign: cross-selling, etc
@property (nonatomic, retain) NSMutableArray *bannersArray;     //

@property (nonatomic, assign) BOOL deletedView;  

@end

@implementation MCMCampaignsManager SYNTHESIZE_SINGLETON_FOR_CLASS(MCMCampaignsManager)

@synthesize campaignContainerView = _campaignContainerView;
@synthesize appstoreContainerView = _appstoreContainerView;
@synthesize campaignsEnabled = _campaignsEnabled;
@synthesize delegate = _delegate;

@synthesize bannersArray = _bannersArray;



#pragma mark - public methods

- (void)addBannerType:(CampaignType)type inView:(UIView*)view {
    [self addBannerType:type inView:view withAppstoreView:nil];
}

- (void)addBannerType:(CampaignType)type inView:(UIView *)view withAppstoreView:(UIView *)appstoreView{
    
    [self hideCampaignView];
    
    self.type = type;
    
    if(self.durationTimer && [self.durationTimer isValid]){
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }

    //time by default
    self.duration = DEFAULT_DURATION;

    //specifies the container view for the banner
    _campaignContainerView = view;
    
    //specifies the container view for the appstore
    _appstoreContainerView = appstoreView;
    
    //request a campaign to the server. this has to be called everytime it's needed to show it.
    [self requestCampaign];
    
    _campaignsEnabled = YES;
}


- (void)removeCurrentBanner{
    
    //removes the current one
    if(self.currentIntersitial){
        [self hideCampaignView];
    }

    _campaignsEnabled = NO;
    self.currentIntersitial = nil;

}
- (void)dealloc{
        
    if(self.durationTimer && [self.durationTimer isValid]){
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
    
    [super dealloc];
}


#pragma mark - private methods

/**
 Method that request the banner to the server.
 @since 2.0.0
 */
- (void)requestCampaign{
    
//    NSString *url = @"https://dl.dropboxusercontent.com/u/23103432/campaignsV2.json";
    
    NSString *url = [NSString stringWithFormat:MCMCAMPAIGN_URL, [[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyMalcomAppId], [MCMCoreUtils uniqueIdentifier]];
    url = [[MCMCoreManager sharedInstance] malcomUrlForPath:url];
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Campaign - MCMCampaignManager url: %@", url]
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    MCMASIHTTPRequest *request = [MCMASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDownloadCache:[MCMASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy];
    [request setCacheStoragePolicy:ASICacheForSessionDurationCacheStoragePolicy];
    [request setTimeOutSeconds:8];
    [request setDelegate:self];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"jsonDownloaded", @"type",nil]];
    [request startAsynchronous];
    
}


/**
 Method that gets randomly weighted a campaign to serve.
 @return MCMCampaignModel campaign selected.
 @since 2.0.0
 */
- (MCMCampaignModel *)getCampaignPerWeight{
    
    
    NSMutableArray *weightedArray = [[NSMutableArray alloc] init];
    
    //generates the array to random weighted selection
    for(int i=0; i<[self.campaignsArray count]; i++){
        
        MCMCampaignModel *campaignModel = [self.campaignsArray objectAtIndex:i];
        
        //adds to the weighted array as ids as weight has
        for(int j=0; j<campaignModel.weight;j++){
            [weightedArray addObject:[NSNumber numberWithInt:i]];
        }
        
    }

    //generates random number
    int selection = arc4random()%[weightedArray count];

    //gets the random position and gets the id written on it. It will be one of the campaigns
    MCMCampaignModel *selectedCampaignModel = [self.campaignsArray objectAtIndex:[[weightedArray objectAtIndex:selection] intValue]];
    [weightedArray release];
    
    return selectedCampaignModel;

}

 
             
/**
Method that gets randomly weighted a campaign to serve.
@return MCMCampaignModel campaign selected.
@since 2.0.0
*/
- (NSMutableArray *)getPromotionCampaignsArray{
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    //generates the array with only the promotion campaigns
    for(int i=0; i<[self.campaignsArray count]; i++){
        
        MCMCampaignModel *campaignModel = [self.campaignsArray objectAtIndex:i];
        
        if (campaignModel.type == IN_APP_PROMOTION) {
            [resultArray addObject:campaignModel];
        }
             
    }
             
    return [resultArray autorelease];
             
}


/**
 Method that shows the selected campaign in the screen.
 @since 2.0.0
 */
- (void)displayCampaign{
    

    //if there are parsed campaigns
    if ([self.campaignsArray count] > 0) {
        
        //if previously there is some banner it will be removed in order to be replaced.
        if(self.currentIntersitial){
            [self hideCampaignView];
        }
        
        if ((self.type == IN_APP_CROSS_SELLING) || (self.type == IN_APP_PROMOTION)) {
            //Get the sources for the current CampaignType
            NSArray *selectionCampaignsArray;
            if (self.type == IN_APP_CROSS_SELLING) {
                //gets the one that fits better depending on the weight of the campaign
                selectionCampaignsArray = [[NSArray alloc] initWithObjects:[self getCampaignPerWeight], nil];
            } else {
                selectionCampaignsArray = [[self getPromotionCampaignsArray] retain];
            }
            
            self.bannersArray = [[NSMutableArray alloc] init];
            
            for (int i=0;i<[selectionCampaignsArray count];i++) {
                //creates a banner with the specifications
                MCMIntersitialBannerViewController *bannerViewController = [[MCMIntersitialBannerViewController alloc] initInView:_campaignContainerView andCampaign:[selectionCampaignsArray objectAtIndex:i]];
                [bannerViewController setDelegate:self];
                [bannerViewController.view setTag:i];
                
                if (self.type == IN_APP_CROSS_SELLING)
                    [bannerViewController setAppstoreContainerView:_appstoreContainerView]; //specifies the appstore container view
                
                [self.bannersArray addObject:bannerViewController];
            }
            
            
            [selectionCampaignsArray release];
        }
        

        [MCMLog log:@"Malcom Campaign - MCMCampaignManager Starting campaign displaying..."
             inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        
    }
    
}

/**
 
 */
- (void)placePromotionBanners:(NSArray*)bannersArray inView:(UIView *)containerView {
    [MCMLog log:@"Malcom Campaign - MCMCampaignManager placeBanners" 
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    int yOffset = 0;
    
    for (int i=0; i<[bannersArray count]; i++) {
        
        [MCMLog log:[NSString stringWithFormat:@"MCMCampaignManager placing banner %d - offset %d",i,yOffset]
             inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        
        MCMIntersitialBannerViewController *currentBanner = [bannersArray objectAtIndex:i];
        
        CGRect frame = currentBanner.view.frame;
        frame.origin.y = yOffset;
        [currentBanner.view setFrame:frame];
        
        yOffset += frame.size.height;
        
        //Remove the view from container
        [currentBanner.view removeFromSuperview];
        //Add current view in proper location
        [containerView addSubview:currentBanner.view];
        
    }
}

- (void)placeCrossSellingBanner:(MCMIntersitialBannerViewController *)bannerViewController inView:(UIView *)containerView {
    //adds the banner to the view
    [containerView addSubview:bannerViewController.view];
    
    [bannerViewController.view setAlpha:0.0f];
    
    //depending on the type of position it will show a bouncing animation
    if((bannerViewController.currentCampaignModel.mediaFeature.position == MIDDLE_LANDSCAPE) ||
       (bannerViewController.currentCampaignModel.mediaFeature.position == MIDDLE_PORTRAIT)){
        
        
        [bannerViewController.bannerButton setTransform:CGAffineTransformMakeScale(0.1, 0.1)];
        [bannerViewController.backgroundFadedView setAlpha:0.0f];
        [bannerViewController.closeButton setAlpha:0.0f];
        
        [UIView animateWithDuration: 0.3
                         animations: ^{
                             bannerViewController.bannerButton.transform = CGAffineTransformMakeScale(1.2, 1.2);
                             [bannerViewController.view setAlpha:1.0f];
                             [bannerViewController.backgroundFadedView setAlpha:0.7f];
                             
                         }
                         completion: ^(BOOL finished){
                             [UIView animateWithDuration:1.0/10.0
                                              animations: ^{
                                                  bannerViewController.bannerButton.transform = CGAffineTransformMakeScale(0.9, 0.9);
                                              }
                                              completion: ^(BOOL finished){
                                                  [UIView animateWithDuration:1.0/5.0
                                                                   animations: ^{
                                                                       bannerViewController.bannerButton.transform = CGAffineTransformIdentity;
                                                                       [bannerViewController.closeButton setAlpha:1.0f];
                                                                       
                                                                   }completion:^(BOOL finished) {
                                                                   }];
                                              }];
                         }];
        
        
    }else{ //or a simple animation of fade in
        
        [UIView animateWithDuration: 0.3 animations: ^{
            [bannerViewController.view setAlpha:1.0f];
        }
                         completion: ^(BOOL finished){}];
    }
    
    
    
    //clears the timer
    if(self.durationTimer && [self.durationTimer isValid]){
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
    
    
    //if duration is not 0 it will create a timer in order to remove and finish the campaign
    if(self.duration != 0){
        self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:self.duration
                                                              target:self
                                                            selector:@selector(finishCampaignView)
                                                            userInfo:nil
                                                             repeats:NO];
    }
    
}


/**
 Method that detects the app did becoming to active and displays another campaign
 @since 2.0.0
 */
- (void)appDidBecomeActiveNotification:(NSNotification *)notification{

    if(_campaignsEnabled){
        [self requestCampaign];
    }
}

/**
 Method that finishes the campaign
 @since 2.0.0
 */
- (void)hideCampaignView{
    
    if(self.currentIntersitial.view.superview){
        [self.currentIntersitial.view removeFromSuperview];
    }

    self.currentIntersitial = nil;
}

- (void)finishCampaignView{
  
    if (self.currentIntersitial && self.currentIntersitial.view.window) {
        [self hideCampaignView];
        
        //notifies by the delegate that the campaign has been finished
        if(self.delegate && [self.delegate respondsToSelector:@selector(campaignViewDidFinish)]){
            [self.delegate campaignViewDidFinish];
        }
    }
    
}

- (void)notifyServer:(NSString *)action andCampaign:(MCMCampaignModel *)campaign{
    
    //url
    NSString *path = [NSString stringWithFormat:MCMCAMPAIGN_HIT_URL,
                      campaign,
                      action,
                      [[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyMalcomAppId],
                      [MCMCoreUtils uniqueIdentifier]];
    
    NSURL *url = [NSURL URLWithString:[[MCMCoreManager sharedInstance] malcomUrlForPath:path]];
    
    //request
    MCMCoreAPIRequest *request = [[MCMCoreAPIRequest alloc] initWithURL:url];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"type", @"campaingHit",nil]];
    [request startSynchronous];
    
    
    NSError *error = [request error];
    
    if ((!error) && ([request responseStatusCode]<402)) {
        NSLog(@"Todo ok: %d", [request responseStatusCode]);
    }
    else {
        
        [MCMLog log:[NSString stringWithFormat:@"Malcom Campaign - MCMCampaignManager Error sending: %@", [request responseStatusMessage]]
             inLine:__LINE__
         fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    }
    
}

#pragma mark ----
#pragma mark ASIHTTPRequest delegate methods
#pragma mark ----

- (void)requestFinished:(MCMASIHTTPRequest *)request {
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Campaign - MCMCampaignManager HTTP CODE: %d", [request responseStatusCode]]
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];

        
    //parses the response
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"jsonDownloaded"]) {
        
        NSData *data = [request responseData];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:nil];
        NSArray *items = [json objectForKey:@"campaigns"];
        
        self.campaignsArray = [[NSMutableArray alloc] initWithCapacity:1];
        
        //parses all the campaigns
        for(int i=0; i<[items count];i++){
            
            //gets the first element of the dictionary
            NSDictionary *dict = [items objectAtIndex:i];
            
            MCMCampaignModel *campaignModel = [[MCMCampaignModel alloc] initWithDictionary:dict];
            [self.campaignsArray addObject:campaignModel];

        }
        
        //notifies it will be shown
        if(self.delegate && [self.delegate respondsToSelector:@selector(campaignViewWillLoad)]){
            [self.delegate campaignViewWillLoad];
        }
        
        //shows a campaign
        [self displayCampaign];
        
    }else{
        //notifies delegate fail
        if(self.delegate && [self.delegate respondsToSelector:@selector(campaignViewDidFailRequest)]){
            [self.delegate campaignViewDidFailRequest];
        }
    }
    
}

- (void)requestFailed:(MCMASIHTTPRequest *)request {
    
    NSError *err = [request error];
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Campaign - MCMCampaignManager Error receiving campaing file: %@", [err description]]
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
}



#pragma mark - MCMIntersitialBannerViewControllerDelegate Methods

- (void)mediaFinishLoading:(MCMCampaignModel *)campaign{
    
    //sends a notification to capture the impression of the view in server
    [self notifyServer:@"IMPRESSION" andCampaign:campaign];
    
    UIView *containerView;
    
    //depending on the situation it will show it in window or in the container view.
    if([self.currentIntersitial needsToDisplayOnWindow] || _campaignContainerView == nil ){ //adds it to the window
        
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        if (!window)
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        
        containerView = [[window subviews] objectAtIndex:0];
        
        //        containerView = [[[UIApplication sharedApplication] delegate] window];
        
    }else{ //adds to the specified view
        containerView = _campaignContainerView;
        
    }
    
    if (self.type == IN_APP_CROSS_SELLING) {
        
        [self placeCrossSellingBanner:[self.bannersArray objectAtIndex:0] inView:containerView];
        
    } else if (self.type == IN_APP_PROMOTION) {
        
        [self placePromotionBanners:self.bannersArray inView:containerView];
    }

    //notifies it is being shown
    if(self.delegate && [self.delegate respondsToSelector:@selector(campaignViewDidLoad)]){
        [self.delegate campaignViewDidLoad];
    }
    
    [MCMLog log:@"Malcom Campaign - MCMCampaignManager Displaying a campaign..."
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
}

- (void)mediaFailedLoading{
 
    //notifies delegate fail
    if(self.delegate && [self.delegate respondsToSelector:@selector(campaignViewDidFailRequest)]){
        [self.delegate campaignViewDidFailRequest];
    }
    
    [MCMLog log:@"Malcom Campaign - MCMCampaignManager Failed campaign displaying..."
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    
}

- (void)mediaClosed{
    
    [self finishCampaignView];
    
}

- (void)bannerPressed:(MCMCampaignModel *)campaign{
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Campaign - MCMCampaignManager Pressed %@",campaign]
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    //notifies it is being shown
    if(self.delegate && [self.delegate respondsToSelector:@selector(campaignPressed:)]){
        
        [self.delegate campaignPressed:campaign.promotionFeature.promotionIdentifier];
    }
    
    [self notifyServer:@"CLICK" andCampaign:campaign];

}

@end
