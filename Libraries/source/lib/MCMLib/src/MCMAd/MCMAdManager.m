//
//  MCMAdManager.m
//  MobiveryApp
//
//  Created by Alfonso Miranda Castro on 20/03/12.
//  Copyright (c) 2012 Malcom. All rights reserved.
//

#import "MCMAdManager.h"
#import "MCMCoreSingleton.h"
#import "MCMCoreDefines.h"
#import "MCMCore.h"
#import "MCMAd.h"
#import "MCMAdDefines.h"


@implementation MCMAdManager SYNTHESIZE_SINGLETON_FOR_CLASS(MCMAdManager)

@synthesize frameChanged = frameChanged_;

- (id)init {

    self = [super init];
    if (self) {
    
        //adWhirlFrame_ = CGRectMake(0, 0, adWhirlView.frame.size.width, adWhirlView.frame.size.height);
        frameChanged_ = NO;
        
        adWhirlView_ = [AdWhirlView requestAdWhirlViewWithDelegate:self];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
        
    }

    return self;

}

- (void)presentAd:(UIViewController *)vc atPosition:(CGRect)position {
    
    adWhirlView_ = [AdWhirlView requestAdWhirlViewWithDelegate:self];
    
    if (position.size.width == 0 && position.size.height == 0) {
        
        CGSize adSize = [adWhirlView_ actualAdSize];
        
        CGRect rect = CGRectMake(position.origin.x, position.origin.y,adSize.width, adSize.height);
        
        [adWhirlView_ setFrame:rect];
        
    }
    else {
    
        [adWhirlView_ setFrame:position];
        
    }
    
    [adWhirlView_ setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [adWhirlView_ setHidden:YES];
	[vc.view addSubview:adWhirlView_];	                                                  
    
}

- (void)relocateAd:(CGPoint)position {
    
    [adWhirlView_ setFrame:CGRectMake(position.x, position.y, adWhirlView_.frame.size.width, adWhirlView_.frame.size.height)];
    
}

- (void)removeAd:(UIViewController *)viewController {
    
    for (int i = 0; i < [[viewController.view subviews] count]; i++) {
        
        id view = [[viewController.view subviews] objectAtIndex:i];
        
        if ([view isKindOfClass:[AdWhirlView class]]) {
            
            [view removeFromSuperview];
            
        }
        
    }
    
    //adWhirlView_ = nil;
    
}

- (void)setAdWhirlFrame:(CGRect)adWhirlFrame {
    
    adWhirlFrame_ = adWhirlFrame;
    frameChanged_ = YES;
    
}

- (CGRect)getAdWhirlFrame {
    
    return adWhirlFrame_;
    
}

- (id)getAd {
    
    adWhirlView_ = [AdWhirlView requestAdWhirlViewWithDelegate:self];
    
    return adWhirlView_;
    
}


#pragma -
#pragma Orientation methods

- (void)deviceOrientationDidChange:(NSNotification *)notification {
 
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (adWhirlView_){
        [adWhirlView_ rotateToOrientation:orientation];  
    }
    
}

-(UIViewController *) getPresentedModalViewController:(UIViewController *) controller{
    while ([controller presentedViewController]) {
        controller = [controller presentedViewController];
    }
    return controller;
}

#pragma mark AdWhirl delegate

- (NSString *)adWhirlApplicationKey {	
    
	return [[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyAdWhirlId];	
}

- (UIViewController *)viewControllerForPresentingModalView {	
    
	NSObject<UIApplicationDelegate> *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if ([appDelegate respondsToSelector:@selector(navigationController)]) {
        
        return [((id) appDelegate) navigationController];
        
    }
    
    if ([appDelegate respondsToSelector:@selector(tabBarController)])
        return [((id) appDelegate) tabBarController];
    
    
    // Checking if current viewController is a modal view
    UIViewController *aux = [self getPresentedModalViewController:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
    if (aux)    return aux;
    
    if ([[[UIApplication sharedApplication] keyWindow] respondsToSelector:@selector(rootViewController)])
        return [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    return nil;
}

- (NSURL *)adWhirlConfigURL{
    NSString *url = [[[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyAdWhirlUrl] stringByAppendingString:kMCMAdConfigPath]; 
    return [NSURL URLWithString:url];
}

- (NSURL *)adWhirlImpMetricURL{
    NSString *url = [[[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyAdWhirlUrl] stringByAppendingString:kMCMAdImpMetricPath]; 
    return [NSURL URLWithString:url];
    
}

- (NSURL *)adWhirlClickMetricURL{
    NSString *url = [[[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyAdWhirlUrl] stringByAppendingString:kMCMAdClickMetricPath]; 
    return [NSURL URLWithString:url];
    
}

- (NSURL *)adWhirlCustomAdURL{
    NSString *url = [[[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyAdWhirlUrl] stringByAppendingString:kMCMAdCustomAdPath]; 
    return [NSURL URLWithString:url];    
}


- (void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlView{
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Ad - AdWhirl banner received. Ad: %@", [adWhirlView description]]
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    //Change size if the banner is not standard
    
    
    //CGRect rect = CGRectMake((adWhirlView.superview.frame.size.width-adSize.width)/2, adWhirlView.superview.frame.size.height-adSize.height, adSize.width, adSize.height);
    
    //    if ([[MCMAdManager sharedInstance] frameChanged]) {
    //    
    //        rect = [[MCMAdManager sharedInstance] getAdWhirlFrame];
    //        
    //    }
    
    //[adWhirlView setFrame:rect];
    //Make it visible
    [adWhirlView setHidden:NO];
    
    //[viewController_.view bringSubviewToFront:adWhirlView];
    
    [adWhirlView.superview performSelectorOnMainThread:@selector(bringSubviewToFront:) withObject:adWhirlView waitUntilDone:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MCMReceiveAd object:adWhirlView];
    
}

- (void)adWhirlDidFailToReceiveAd:(AdWhirlView *)adWhirlView usingBackup:(BOOL)yesOrNo{
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Ad - AdWhirl failed to receive an ad. Check your appId is correct. Ad: %@", [adWhirlView description]]
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MCMFailReceiveAd object:adWhirlView];
    
}

- (void)adWhirlReceivedNotificationAdsAreOff:(AdWhirlView *)adWhirlView {
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Ad - AdWhirl failed to show an ad because they are off. Ad: %@", [adWhirlView description]] 
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MCMNotificationAdsAreOff object:adWhirlView];
    
}

- (BOOL)adWhirlTestMode{
    return [[MCMCoreManager sharedInstance] developmentMode];
}

@end
