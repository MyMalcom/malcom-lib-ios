
#import "MCMStatsAdapter.h"
#import "MCMStats.h"
#import "MCMCore.h"
#import "MCMCoreDefines.h"

@implementation MCMStatsAdapter


- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    [MCMStatsManager initAndStartBeaconWithApplicationCode:[[MCMCoreManager sharedInstance] malcomAppId] useCoreLocation:YES useOnlyWiFi:NO];
}

-(void) applicationWillTerminate:(UIApplication *)application{
    [[MCMStatsManager sharedInstance] endBeacon];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    [[MCMStatsManager sharedInstance] endBeacon];
}
- (void)applicationWillEnterForeground:(UIApplication *)application{
    [MCMStatsManager initAndStartBeaconWithApplicationCode:[[MCMCoreManager sharedInstance] malcomAppId] useCoreLocation:YES useOnlyWiFi:NO];
}

- (void)viewAppear:(UIViewController *)vc {
    NSString *name = [vc title];
    if ([name length]<=0)
        name=NSStringFromClass([vc class]);    
    
    [MCMLog log:[NSString stringWithFormat:@"Subbeacon init: %@", name] 
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    [[MCMStatsManager sharedInstance] startSubBeaconWithName:name timeSession:YES];	
}

- (void) viewDisappear:(UIViewController *)vc{
    NSString *name = [vc title];
    if ([name length]<=0)
        name=NSStringFromClass([vc class]);    
    [[MCMStatsManager sharedInstance] endSubBeaconWithName:name];	    
}


@end
