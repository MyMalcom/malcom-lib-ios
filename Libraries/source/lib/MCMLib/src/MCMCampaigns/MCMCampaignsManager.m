//
//  MCMCampaignsManager.m
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 25/01/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import "MCMCampaignsManager.h"
#import "MCMCoreSingleton.h"
#import "MCMIntersitialBannerViewController.h"
#import "MCMASIHTTPRequest.h"
#import "MCMASIDownloadCache.h"
#import "MCMCoreUtils.h"
#import "MCMLog.h"
#import "MCMCoreManager.h"
#import "MCMCore.h"

@implementation MCMCampaignsManager SYNTHESIZE_SINGLETON_FOR_CLASS(MCMCampaignsManager)

- (void)addBanner:(UIView *)view {
    
    NSLog(@"Entramos en addBanner");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(campaingHit:) name:@"CAMPAINGHIT" object:nil];
        
    //NSString *url = @"https://dl.dropbox.com/u/53608360/campaing.json";
    NSString *url = [NSString stringWithFormat:@"v1/campaigns/application/%@/udid/%@", [[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyMalcomAppId], [MCMCoreUtils uniqueIdentifier]];
    url = [[MCMCoreManager sharedInstance] malcomUrlForPath:url];
    
    NSLog(@"________________url: %@", url);
    
    _showView = view;
    
    MCMASIHTTPRequest *request = [MCMASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDownloadCache:[MCMASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setTimeOutSeconds:8];
    [request setDelegate:self];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"jsonDownloaded", @"type",nil]];
    [request startAsynchronous];
    
    //NSURL * jsonurl=[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSData* data = [NSData dataWithContentsOfURL: jsonurl];
    
    
    
}

#pragma mark ----
#pragma mark ASIHTTPRequest delegate methods
#pragma mark ----


- (void)requestFinished:(MCMASIHTTPRequest *)request {
    
    NSLog(@"________________Request finished!!!!");
    
    if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"jsonDownloaded"]) {
        
        NSData *data = [request responseData];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:nil];
        NSArray *items = [json objectForKey:@"campaigns"];
        
        if ([items count] > 0) {
            
            NSDictionary *dict = [items objectAtIndex:0];
            MCMIntersitialBannerViewController *intersitialView = [[MCMIntersitialBannerViewController alloc] init];
            intersitialView.urlImage = [dict objectForKey:@"media"];
            intersitialView.urlAppStore = [dict objectForKey:@"link"];
            intersitialView.type = [dict objectForKey:@"type"];
            intersitialView.position = [dict objectForKey:@"position"];
            
            [_showView addSubview:intersitialView.view];
            
            if (_campaingId != nil) {
                
                [_campaingId release];
                _campaingId = nil;
                
            }
            
            _campaingId = [[dict objectForKey:@"id"] retain];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CAMPAINGHIT" object:@"IMPRESSION"];
            
        }
        
    }
    
}

- (void)requestFailed:(MCMASIHTTPRequest *)request
{
    NSError *err = [request error];
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Campaing - Error receiving campaing file: %@", [err description]]
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
}

- (void)campaingHit:(NSNotification *)notification {
    
    NSString *path = [NSString stringWithFormat:@"v1/campaign/%@/hit/%@/application/%@/udid/%@", _campaingId, notification.object, [[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyMalcomAppId], [MCMCoreUtils uniqueIdentifier]];
    
    NSURL *url = [NSURL URLWithString:[[MCMCoreManager sharedInstance] malcomUrlForPath:path]];
    
    NSLog(@"______________url: %@", url);
    
    MCMASIHTTPRequest *request = [MCMASIHTTPRequest requestWithURL:url];
    [request setDownloadCache:[MCMASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setTimeOutSeconds:8];
    [request setDelegate:self];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"type", @"campaingHit",nil]];
    [request startAsynchronous];
    
}

@end
