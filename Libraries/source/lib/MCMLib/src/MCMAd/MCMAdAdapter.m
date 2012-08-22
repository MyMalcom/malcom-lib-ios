
#import "MCMAdAdapter.h"
#import "MCMAd.h"
#import "MCMAdDefines.h"
#import "MCMCore.h"
#import "MCMCoreDefines.h"
#import "AdWhirlView.h"
//#import "MCMAdManager.h"
#import <UIKit/UIKit.h>

@implementation MCMAdAdapter

- (id) init{
    if ((self=[super init])){
        adViewDict_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc {
    [adViewDict_ release];
    [super dealloc];
}

- (void) viewDidLoad:(UIViewController *)vc{    
    if ([[[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyAdWhirlId] length]<=0){
        
        [MCMLog log:@"Malcom Ad - The module has been included in the binary but no AdWhirlId configured in MCMCore-Info.plist" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        return;
    
    }

    //Check the ad is not disabled
    if ([vc respondsToSelector:@selector(shouldLoadAd)]){
        if ([vc performSelector:@selector(shouldLoadAd)]==NO){
            [adViewDict_ removeObjectForKey:[NSString stringWithFormat:@"%x", vc]];
            return;
        }
    }
    
    //AdWhirl methods	
	AdWhirlView *adWhirlView = [AdWhirlView requestAdWhirlViewWithDelegate:self];	
	
    CGSize adSize = [adWhirlView actualAdSize];
    
    [adWhirlView setFrame:CGRectMake((adWhirlView.superview.frame.size.width-adSize.width)/2, adWhirlView.superview.frame.size.height-adSize.height, adSize.width, adSize.height)];
    
    [adWhirlView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [adWhirlView setHidden:YES];
	[vc.view addSubview:adWhirlView];	                                                  

    [adViewDict_ setObject:adWhirlView forKey:[NSString stringWithFormat:@"%x", vc]];
}

- (void) viewRotate:(UIViewController *)vc toOrientation:(UIInterfaceOrientation)orientation{
    
    AdWhirlView *adWhirlView = [adViewDict_ objectForKey:[NSString stringWithFormat:@"%x", vc]];
    if (adWhirlView){
        [adWhirlView rotateToOrientation:orientation];  
    }
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
    
    [MCMLog log:[NSString stringWithFormat:@"AdWhirl banner received. Ad: %@", [adWhirlView description]] 
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    //Change size if the banner is not standard
    CGSize adSize = [adWhirlView actualAdSize];
        
    CGRect rect = CGRectMake((adWhirlView.superview.frame.size.width-adSize.width)/2, adWhirlView.superview.frame.size.height-adSize.height, adSize.width, adSize.height);
    
//    if ([[MCMAdManager sharedInstance] frameChanged]) {
//    
//        rect = [[MCMAdManager sharedInstance] getAdWhirlFrame];
//        
//    }
    
    [adWhirlView setFrame:rect];
    //Make it visible
    [adWhirlView setHidden:NO];
    [adWhirlView.superview performSelectorOnMainThread:@selector(bringSubviewToFront:) withObject:adWhirlView waitUntilDone:YES];
    
}

- (void)adWhirlDidFailToReceiveAd:(AdWhirlView *)adWhirlView usingBackup:(BOOL)yesOrNo{
    
    [MCMLog log:[NSString stringWithFormat:@"AdWhirl failed to receive an ad. Check your appId is correct. Ad: %@", [adWhirlView description]] 
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
}

- (void)adWhirlReceivedNotificationAdsAreOff:(AdWhirlView *)adWhirlView {
     
    [MCMLog log:[NSString stringWithFormat:@"AdWhirl failed to show an ad because they are off. Ad: %@", [adWhirlView description]] 
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
}

- (BOOL)adWhirlTestMode{
    return [[MCMCoreManager sharedInstance] developmentMode];
}

@end
