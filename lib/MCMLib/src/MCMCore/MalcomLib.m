//
//  MalcomLib.m
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 19/04/12.
//  Copyright (c) 2012 Malcom. All rights reserved.
//

#import "MalcomLib.h"
#import "MCMCoreDefines.h"
#import "MCMCore.h"
#import "MCMConfigManager.h"
#import "MCMSplashViewController.h"
#import "MCMStatsManager.h"
//#import "MCMAdManager.h"
#import "MCMNotificationManager.h"


@implementation MalcomLib


//  CORE

+ (void)initWithUUID:(NSString *)uuid andSecretKey:(NSString *)secretKey withAdId:(NSString *)adId {
    
    [self initWithUUID:uuid andSecretKey:secretKey withAdId:adId urlApi:kMCMBaseUrl andLogActivated:NO];
    
}

+ (void)initWithUUID:(NSString *)uuid andSecretKey:(NSString *)secretKey withAdId:(NSString *)adId andLogActivated:(BOOL)logActivated {
    
    [self initWithUUID:uuid andSecretKey:secretKey withAdId:adId urlApi:kMCMBaseUrl andLogActivated:logActivated];
    
}

+ (void)initWithUUID:(NSString *)uuid andSecretKey:(NSString *)secretKey withAdId:(NSString *)adId urlApi:(NSString *)urlApi andLogActivated:(BOOL)logActivated {
    
    //  Activamos/Desactivamos el log
    
    [self showLog:logActivated];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:kMCMCoreInfoPlistName ofType:nil];
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:bundlePath];
    
    if (settings == nil) {
        
        settings = [[NSMutableDictionary alloc] init];
        
    }
    
    [settings setValue:uuid forKey:kMCMCoreKeyMalcomAppId];
    [settings setValue:secretKey forKey:kMCMCoreKeyAssetsAppSecretKey];
    
    if (bundlePath != nil) {
        
        [settings writeToFile:bundlePath atomically:YES];
        
    }
    else {
        
        //[settings setValue:kMCMBaseUrl forKey:kMCMCoreKeyMalcomBaseUrl];
        [settings setValue:urlApi forKey:kMCMCoreKeyMalcomBaseUrl];
        [settings setValue:kMCMAdwhirlURL forKey:@"AdWhirlBaseUrl"];
        [settings setValue:adId forKey:@"AdWhirlId"];
        
        [[NSUserDefaults standardUserDefaults]  setObject:settings  forKey:kMCMCoreInfoPlistName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    // Install Crash Manager
	//[[CrashManager sharedInstance] manageCrashes];
	//[[CrashManager sharedInstance] setCrashDelegate:self selector:@selector(notifyException:stackTrace:)];
    
}

+ (void)showLog:(BOOL)logActivated {
    
    [[NSUserDefaults standardUserDefaults]  setObject:[NSNumber numberWithBool:logActivated]  forKey:KMCMLogActivated];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

//  CONFIGURATION

+ (void)loadConfiguration:(UIViewController *)viewController withDelegate:(id)delegate withLabel:(BOOL) isLabel {
    
    [[MCMConfigManager sharedInstance] loadSettingsWithAppId:[[MCMCoreManager sharedInstance] malcomAppId]];
    
    //Create a splashController
	MCMConfigSplashViewController *splashController = [[MCMConfigSplashViewController alloc] initWithNibName:nil bundle:nil];
    
	[((MCMConfigSplashViewController *) splashController) setDelegate:((id<MCMConfigSplashDelegate>)delegate)];
       
    //splashLoaded_=YES;
    
    //Add Splash to main window
    [viewController.view addSubview:splashController.view];    
    [splashController.view.superview performSelector:@selector(bringSubviewToFront:) withObject:splashController.view afterDelay:0];
    
    splashController.statusLabel.hidden = !isLabel;
    
    //Notify the AppDelegate
    if ([viewController respondsToSelector:@selector(splashLoaded:)]){
        [((id<MCMConfigApplicationDelegate>) viewController) splashLoaded:splashController];
    }
    
}

+ (void)loadConfiguration:(UIViewController *)viewController withDelegate:(id)delegate withSplash:(BOOL) isSplash {
    
    [[MCMConfigManager sharedInstance] loadSettingsWithAppId:[[MCMCoreManager sharedInstance] malcomAppId]];
    
    //Create a splashController
	MCMConfigSplashViewController *splashController = [[MCMConfigSplashViewController alloc] initWithNibName:nil bundle:nil];
    
	[((MCMConfigSplashViewController *) splashController) setDelegate:((id<MCMConfigSplashDelegate>)delegate)];
    
    //splashLoaded_=YES;
    
    if (isSplash) {
        
        //Add Splash to main window
        [viewController.view addSubview:splashController.view];    
        [splashController.view.superview performSelector:@selector(bringSubviewToFront:) withObject:splashController.view afterDelay:0];
        
        //splashController.statusLabel.hidden = !isLabel;
        
        //Notify the AppDelegate
        if ([viewController respondsToSelector:@selector(splashLoaded:)]){
            [((id<MCMConfigApplicationDelegate>) viewController) splashLoaded:splashController];
        }
        
    }
    
}

+ (NSString *)getAdvanceConfigurationForKey:(NSString *)key valueDefault:(NSString *)vDefault {
    
    NSString *value = [[MCMConfigManager sharedInstance] settingForKey:key];
    
    if (value == nil) {
        
        value = vDefault;
        
    }
    
    return value;
    
}

//  STATS

+ (void)initAndStartBeacon:(BOOL)userLocation useOnlyWiFi:(BOOL)wifiState {
    
    [MCMStatsManager initAndStartBeaconWithApplicationCode:[[MCMCoreManager sharedInstance] malcomAppId] useCoreLocation:userLocation useOnlyWiFi:wifiState];
    
}

+ (void)endBeacon {
    
    [[MCMStatsManager sharedInstance] endBeacon];
    
}

+ (void)startBeaconWithName:(NSString *)name {
    
    [[MCMStatsManager sharedInstance] startSubBeaconWithName:name timeSession:YES];
    
}

+ (void)endBeaconWithName:(NSString *)name {
    
    [[MCMStatsManager sharedInstance] endSubBeaconWithName:name];
    
}

+ (void) setTags:(NSArray *)tags {
	
    [[NSUserDefaults standardUserDefaults] setObject:tags forKey:@"mcm_tags"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
}

+ (NSArray *) getTags {
    
	return [[NSUserDefaults standardUserDefaults] arrayForKey:@"mcm_tags"];

}

//  Notifications

+ (void)startNotifications:(UIApplication *)application withOptions:(NSDictionary *)launchOptions isDevelopmentMode:(BOOL)developmentMode {
    
    [[NSUserDefaults standardUserDefaults]  setObject:[NSNumber numberWithBool:developmentMode]  forKey:@"developmentMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Register the app in Apple APNS to use push notifications
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                     UIRemoteNotificationTypeSound | 
                                                     UIRemoteNotificationTypeAlert)];
    
    
    // Setting APNS badge to none initially
    application.applicationIconBadgeNumber = 0;
    
    //	Verifying if application was run in a normal way or was opened from a push notification
    if (launchOptions == nil) {
        //	Normal tasks if appication was run in a normal way
        // ...
        [MCMLog log:@"App running in normal mode" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        
        
    } else {
        // Initialization task when app was run from a push notification
        [MCMLog log:[NSString stringWithFormat:@"App running from push notification with pushOption -> %@", [[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] description]] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        
        //Receive the notification
        [MCMNotificationManager didReceiveRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
        
        //Process the notification
        [MCMNotificationManager processRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
        
    }
    
}

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    //	Calling method which registers the application in Malcom service.     
    if ([[MCMCoreManager sharedInstance] developmentMode]){    
        
        [MCMNotificationManager didRegisterForRemoteNotificationsInSANDBOX:devToken];  
        
    }
    else {
        
        [MCMNotificationManager didRegisterForRemoteNotificationsWithDeviceToken:devToken];
        
    }
    
}

+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    //	Calling method that manages errors
	[MCMNotificationManager didFailToRegisterForRemoteNotificationsWithError:err];
    
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo active:(BOOL)appActive {
    
    // Initialization task when app was run from a push notification
    [MCMLog log:[NSString stringWithFormat:@"Push notification received while app running with pushOption -> %@", [userInfo description]] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    //Receive the notification
	[MCMNotificationManager didReceiveRemoteNotification:userInfo];
    
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
    // Create an alert message sent in the push notification
    NSString *alertMsg=nil;
    if( [[userInfo objectForKey:@"aps"] objectForKey:@"alert"] != NULL) {
        
        alertMsg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]; 
        
    }
    
    if (([alertMsg length]>0) && (appActive==YES)){        
                
        // Showing an alert with push notification message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:alertMsg delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                              otherButtonTitles:NSLocalizedString(@"View", @""),nil];
        [alert show];
        [alert release];	
        
    }
    //If no alert found or app was inactive, process the message
    else {
        
        [MCMNotificationManager processRemoteNotification:userInfo];
        
    }
    
}

/*- (void) notifyException:(NSException*) exception stackTrace:(NSArray*) stackTrace
{
	// Oh no!  We crashed!
	// Time to output some stuff to the console.
	
	// Note: Any EXC_BAD_ACCESS crashes (such as accessing a deallocated object) will
	// cause the app to close stdout, so you won't see this trace in such a case.
    
	NSLog(@"Exception:\n%@\n", exception);
    
	NSLog(@"Full Trace:\n%@\n", [[StackTracer sharedInstance] printableTrace:stackTrace]);
    
	NSArray* intelligentTrace = [[StackTracer sharedInstance] intelligentTrace:stackTrace];
	NSLog(@"Condensed Intelligent Trace:\n%@", [[StackTracer sharedInstance] condensedPrintableTrace:intelligentTrace]);
}*/

@end
