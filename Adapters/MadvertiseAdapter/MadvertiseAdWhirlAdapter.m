//
//  MadvertiseAdWhirlAdapter.m
//  
//
//  Created by Alfonso Miranda Castro on 14/03/12.
//  Copyright (c) 2012 Malcom. All rights reserved.
//

#import "MadvertiseAdWhirlAdapter.h"
#import "MadvertiseView.h"
#import "MadvertiseTracker.h"
#import "MalcomLib.h"


@implementation MadvertiseAdWhirlAdapter

#pragma mark -
#pragma mark Metodos del singleton

static MadvertiseAdWhirlAdapter *sharedMadvertiseInstance = nil;

- (id) init
{
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}

+ (MadvertiseAdWhirlAdapter *)sharedInstance {
    @synchronized(self) {
        if (sharedMadvertiseInstance == nil) {
            sharedMadvertiseInstance = [[self alloc] init];
        }
    }
    return sharedMadvertiseInstance;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedMadvertiseInstance == nil) {
            sharedMadvertiseInstance = [super allocWithZone:zone];
            return sharedMadvertiseInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (id)autorelease {
    return self;
}

- (id)initWithMadvertise:(AdWhirlView *)adWhirl {
    
    //viewController_ = viewController;
    //adWhirlView_ = adWhirl;
    //[self getAd];
    
//    MadvertiseView *ad = [MadvertiseView loadAdWithDelegate:self withClass:MadvertiseAdClassMMA placementType:MRAdViewPlacementTypeInline secondsToRefresh:30];
//    [ad place_at_x:0 y:-3];
//    [adWhirl addSubview:ad];
//    [adWhirl bringSubviewToFront:ad];
    //[ad release];
    
    
    
    MadvertiseView *ad = [MadvertiseView loadAdWithDelegate:self withClass:MadvertiseAdClassMMA placementType:MRAdViewPlacementTypeInline secondsToRefresh:30];
    MadvertiseView *ad2 = [MadvertiseView loadRichMediaAdWithDelegate:self]; // fullscreen richmedia ad (overlay)
    
    [ad2 place_at_x:0 y:410];
    //[adView addSubview:ad2];
    //[adView bringSubviewToFront:ad2];
    [[adWhirl superview] addSubview:ad2];
    [[adWhirl superview] bringSubviewToFront:ad2];
    [ad place_at_x:0 y:410];
//    [adView addSubview:ad];
//    [adView bringSubviewToFront:ad];
    
    [[adWhirl superview] addSubview:ad];
    [[adWhirl superview] bringSubviewToFront:ad];
    
    
    //[ad2 addSubview:ad];
    
    
    //[adWhirl replaceBannerViewWith:ad2]; 
    
    
    return self;
    
}

#pragma mark -
#pragma mark MadvertiseDelegateProtocol Methods

- (NSString *) appId {
    
    //return [[MCMConfigManager sharedInstance] settingForKey:@"idMadvertise"];
    return [MalcomLib getAdvanceConfigurationForKey:@"idMadvertise" valueDefault:@"kI9Xq8aD"];
    
}

- (BOOL) debugEnabled {
    return YES;
}

- (double) durationOfBannerAnimation{
    return 2.0;
}

- (MadvertiseAnimationClass) bannerAnimationTyp{
    // topToBottom:
    // curlDown:
    // fade:
    return MadvertiseAnimationClassFade;
}

//- (NSString*) adServer {
//  return @"http://192.168.1.51:9292";
//}

- (CLLocationCoordinate2D) location {
    CLLocationCoordinate2D _location = [MalcomLib getLocation].coordinate;// { 8.807081, 53.074981 };
    return _location;
}

- (BOOL) downloadTrackerEnabled {
    return YES;
}

/*- (NSString*)age {
    return @"21";
}

- (NSString *) gender {
    return @"M";
}*/

#pragma mark - 
#pragma mark Notifications

- (void) onAdLoadedSuccessfully:(NSNotification*)notify {
    MadLog(@"successfully loaded with code: %@",[notify object]);
}

- (void) onAdLoadedFailed:(NSNotification*)notify {
    MadLog(@"ad load faild with code: %@",[notify object]);
}

@end
