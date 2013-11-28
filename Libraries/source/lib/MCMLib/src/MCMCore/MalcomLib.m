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
#import "MCMNotificationManager.h"
#import "MCMCampaignsManager.h"
#import "MCMStatsDefines.h"

@interface MalcomLib ()

+ (void)privateEndBeacon;

@end

@implementation MalcomLib

#pragma mark - Core methods

+ (void)initWithUUID:(NSString *)uuid andSecretKey:(NSString *)secretKey {
    [self initWithUUID:uuid andSecretKey:secretKey withAdId:nil urlApi:kMCMBaseUrl andLogActivated:NO];
}

+ (void)initWithUUID:(NSString *)uuid andSecretKey:(NSString *)secretKey withAdId:(NSString *)adId {
    
    [self initWithUUID:uuid andSecretKey:secretKey withAdId:adId urlApi:kMCMBaseUrl andLogActivated:NO];
    
}

+ (void)initWithUUID:(NSString *)uuid andSecretKey:(NSString *)secretKey withAdId:(NSString *)adId andLogActivated:(BOOL)logActivated {
    
    [self initWithUUID:uuid andSecretKey:secretKey withAdId:adId urlApi:kMCMBaseUrl andLogActivated:logActivated];
    
}

+ (void)initWithUUID:(NSString *)uuid andSecretKey:(NSString *)secretKey withAdId:(NSString *)adId urlApi:(NSString *)urlApi andLogActivated:(BOOL)logActivated {
    
    //  Activamos/Desactivamos el log
    [MCMLog log:[NSString stringWithFormat:@"Malcom - SDK Version: %@", MCMVersionSDK] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    [self showLog:logActivated];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:kMCMCoreInfoPlistName ofType:nil];
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:bundlePath];
    
    if (settings == nil) {
        
        settings = [[NSMutableDictionary alloc] init];
        
    }
    
    [settings setValue:uuid forKey:kMCMCoreKeyMalcomAppId];
    [settings setValue:secretKey forKey:kMCMCoreKeyAssetsAppSecretKey];
    
    [settings setValue:urlApi forKey:kMCMCoreKeyMalcomBaseUrl];
    [settings setValue:kMCMAdwhirlURL forKey:@"AdWhirlBaseUrl"];
    if (adId) {
        [settings setValue:adId forKey:@"AdWhirlId"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:kMCMCoreInfoPlistName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (bundlePath != nil) {
        [settings writeToFile:bundlePath atomically:YES];
    }
    
	[settings release];
	
    // Automatic initialization
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeMalcom)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

+ (void)showLog:(BOOL)logActivated {
    
    [[NSUserDefaults standardUserDefaults]  setObject:[NSNumber numberWithBool:logActivated]  forKey:KMCMLogActivated];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (NSString *)getUDID {
    
    return [MCMCoreUtils uniqueIdentifier];
    
}

+ (NSString *)getMalcomID {
    
    return [MCMCoreUtils deviceIdentifier];
    
}

#pragma mark - Configuration methods

+ (void)loadConfiguration:(UIViewController *)viewController withDelegate:(id)delegate withLabel:(BOOL) isLabel {
    
    [[MCMConfigManager sharedInstance] loadSettingsWithAppId:[[MCMCoreManager sharedInstance] malcomAppId]];
    
    //Create a splashController
	MCMConfigSplashViewController *splashController = [[MCMConfigSplashViewController alloc] initWithNibName:nil bundle:nil];
    
	[((MCMConfigSplashViewController *) splashController) setDelegate:((id<MCMConfigSplashDelegate>)delegate)];
       
    //splashLoaded_=YES;
    [splashController.view setFrame:viewController.view.frame];
    
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IntersitialBringToFront" object:nil];
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

+ (NSString *)sdkVersion {
    
    return MCMVersionSDK;
    
}

#pragma mark - Stats methods

+ (void)initAndStartBeacon{
    
    NSLog(@"Malcom initAndStartBeacon");

    [self initAndStartBeacon:[[MCMStatsManager sharedInstance] coreLocation]];
}

+ (void)initAndStartBeacon:(BOOL)userLocation{
    [self initAndStartBeacon:userLocation useOnlyWiFi:NO];
}


+ (void)initAndStartBeacon:(BOOL)userLocation useOnlyWiFi:(BOOL)wifiState {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(privateEndBeacon)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(privateEndBeacon)
                                                 name:UIApplicationWillTerminateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeMalcom)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAppInactive)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    
    [MCMStatsManager initAndStartBeaconWithApplicationCode:[[MCMCoreManager sharedInstance] malcomAppId] useCoreLocation:userLocation useOnlyWiFi:wifiState];
    
}

+ (void)resumeMalcom{
    [self initAndStartBeacon];
    [self setAppActive];
}

+ (void)endBeacon {
    NSLog(@"[MalcomLib endBeacon] - This method is no more needed");
}

+ (void)privateEndBeacon {
    [[MCMStatsManager sharedInstance] endBeacon];
}

+ (void)startBeaconWithName:(NSString *)name {
    
    [[MCMStatsManager sharedInstance] startSubBeaconWithName:name forType:TYPE_CUSTOM andParams:nil timeSession:YES];
    
}

+ (void)startBeaconWithName:(NSString *)name andParams: (NSDictionary *) params andTimeSession: (BOOL)timeSession{
    
    [[MCMStatsManager sharedInstance] startSubBeaconWithName:name forType:TYPE_CUSTOM andParams:params timeSession:timeSession];
    
}

+ (void)endBeaconWithName:(NSString *)name {
    
    [[MCMStatsManager sharedInstance] endSubBeaconWithName:name andParams:nil];
    
}

+ (void)endBeaconWithName:(NSString *)name andParams: (NSDictionary *) params{
    
    [[MCMStatsManager sharedInstance] endSubBeaconWithName:name andParams:params];
    
}

+ (void)identifyUserWithName: (NSString *)name mail: (NSString *)mail {
    [self identifyUserWithName:name mail:mail andParams:[[[NSMutableDictionary alloc] initWithCapacity:1] autorelease]];
}

+ (void)identifyUserWithName: (NSString *)name mail: (NSString *)mail andParams: (NSDictionary *)params {
    
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    [userDictionary setObject:name forKey:@"name"];
    [userDictionary setObject:mail forKey:@"mail"];
    [userDictionary addEntriesFromDictionary:params];
    
    [[MCMStatsManager sharedInstance] startSubBeaconWithName:@"app_user" forType:TYPE_SPECIAL andParams:userDictionary timeSession:NO];
	[userDictionary release];
	
}

+ (void)registerRevenueWithName: (NSString *)name SKU: (NSString *)SKU price: (float)price currencyCode: (NSString *)currency andAmount: (int)amount{
    
    NSMutableDictionary *revenueDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    [revenueDictionary setObject:name forKey:@"name"];
    [revenueDictionary setObject:SKU forKey:@"SKU"];
    [revenueDictionary setObject:[NSString stringWithFormat:@"%f", price] forKey:@"price"];
    [revenueDictionary setObject:currency forKey:@"currencyCode"];
    [revenueDictionary setObject:[NSString stringWithFormat:@"%d", amount] forKey:@"amount"];
    
    [[MCMStatsManager sharedInstance] startSubBeaconWithName:@"revenue" forType:TYPE_SPECIAL andParams:revenueDictionary timeSession:NO];
	[revenueDictionary release];
	
}

+(void)trackView:(NSString *)name{
    
    NSMutableDictionary *screenViewDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    [screenViewDictionary setObject:name forKey:@"name"];

    [[MCMStatsManager sharedInstance] startSubBeaconWithName:@"screenview" forType:TYPE_SPECIAL andParams:screenViewDictionary timeSession:NO];
	[screenViewDictionary release];
	
}

+ (void)setTags:(NSArray *)tags {
    [MCMStatsManager setTags:tags];
}

+ (NSArray *)getTags {
	return [MCMStatsManager getTags];
}

+ (void)addTag:(NSString *)tagName {
    [MCMStatsManager addTag:tagName];
}

+ (void)removeTag:(NSString *)tagName {
    [MCMStatsManager removeTag:tagName];
}

+ (void)removeAllTags {
    [MCMStatsManager setTags:@[]];
}



+ (void)setUserMetadata:(NSString *)userMetadata {
	
    [[NSUserDefaults standardUserDefaults] setObject:userMetadata forKey:@"mcm_user_metadata"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
}

+ (NSString *)getUserMetadata {
    
	return [[NSUserDefaults standardUserDefaults] stringForKey:@"mcm_user_metadata"];
    
}

+ (CLLocation *)getLocation {
    
    return [MCMStatsManager sharedInstance].location;
    
}


#pragma mark - Notification methods

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
        [MCMLog log:@"Malcom - App running in normal mode" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        
        
    } else {
        // Initialization task when app was run from a push notification
        [MCMLog log:[NSString stringWithFormat:@"Malcom - App running from push notification with pushOption -> %@", [[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] description]] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        
        //Receive the notification
        [MCMNotificationManager didReceiveRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
        
        //Process the notification
        [MCMNotificationManager processRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
        
    }
}

+ (void)startNotifications:(UIApplication *)application withOptions:(NSDictionary *)launchOptions{
    [self startNotifications:application withOptions:launchOptions isDevelopmentMode:NO];
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
    [MCMLog log:[NSString stringWithFormat:@"Malcom - Push notification received while app running with pushOption -> %@", [userInfo description]] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    //Receive the notification
	[MCMNotificationManager didReceiveRemoteNotification:userInfo];
    
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
    // Create an alert message sent in the push notification
    NSString *alertMsg=nil;
    if( [[userInfo objectForKey:@"aps"] objectForKey:@"alert"] != NULL) {
        
        alertMsg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]; 
        
    }
    
    if (([alertMsg length]>0) && (appActive==YES)){        
        
        NSDictionary *push = [userInfo retain];
        
        [[NSUserDefaults standardUserDefaults] setObject:push forKey:@"mcm_push_dictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        // Showing an alert with push notification message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:alertMsg delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                              otherButtonTitles:NSLocalizedString(@"View", @""),nil];
        alert.delegate = self;
        [alert show];
        [alert release];	
        
    }
    //If no alert found or app was inactive, process the message
    else {
        
        [MCMNotificationManager processRemoteNotification:userInfo];
        
    }
    
}

+ (void)setAppActive{
        
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"mcm_appActive"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
+ (void)setAppActive:(BOOL)active {
    
    [[NSUserDefaults standardUserDefaults] setBool:active forKey:@"mcm_appActive"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (void) setAppInactive{

    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"mcm_appActive"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getAppActive {
    
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"mcm_appActive"] boolValue];
    
}

//  Campaings

+ (void)addCampaignBanner:(UIView*)view DEPRECATED_ATTRIBUTE{

    [self addCampaignBanner:view withAppstoreContainerView:nil withDelegate:nil];
}

+ (void)addCampaignBanner:(UIView*)view withDelegate:(id)delegate DEPRECATED_ATTRIBUTE{
    
    [self addCampaignBanner:view withAppstoreContainerView:nil withDelegate:delegate];
}

+(void)addCampaignBanner:(UIView *)view withAppstoreContainerView:(UIView *)appStoreContainerView DEPRECATED_ATTRIBUTE{
    
    [self addCampaignBanner:view withAppstoreContainerView:appStoreContainerView withDelegate:nil];
}

+(void)addCampaignBanner:(UIView *)view withAppstoreContainerView:(UIView *)appStoreContainerView withDelegate:(id)delegate DEPRECATED_ATTRIBUTE{
    
    [[MCMCampaignsManager sharedInstance] addBannerType:IN_APP_CROSS_SELLING inView:view withAppstoreView:appStoreContainerView];
    
    if(delegate != nil){
        [[MCMCampaignsManager sharedInstance] setDelegate:delegate];
    }
}

// Multitype campaigns

+ (void)addCampaignCrossSelling:(UIView*)view{
    
    [self addCampaignCrossSelling:view withAppstoreContainerView:nil withDelegate:nil];
}

+ (void)addCampaignCrossSelling:(UIView*)view withDelegate:(id)delegate{
    
    [self addCampaignCrossSelling:view withAppstoreContainerView:nil withDelegate:delegate];
}

+(void)addCampaignCrossSelling:(UIView *)view withAppstoreContainerView:(UIView *)appStoreContainerView{
    
    [self addCampaignCrossSelling:view withAppstoreContainerView:appStoreContainerView withDelegate:nil];
}

+(void)addCampaignCrossSelling:(UIView *)view withAppstoreContainerView:(UIView *)appStoreContainerView withDelegate:(id)delegate{
    
    [[MCMCampaignsManager sharedInstance] addBannerType:IN_APP_CROSS_SELLING inView:view
                                       withAppstoreView:appStoreContainerView
                                         andPlaceHolder:nil];
    
    if(delegate != nil){
        [[MCMCampaignsManager sharedInstance] setDelegate:delegate];
    }
}

+ (void)addCampaignCrossSelling:(UIView*)view
      withAppstoreContainerView:(UIView*)appStoreContainerView
                   withDelegate:(id<MCMCampaignsManagerDelegate>)delegate
                 andPlaceHolder:(UIImage *)placeHolder {
    [[MCMCampaignsManager sharedInstance] addBannerType:IN_APP_CROSS_SELLING
                                                 inView:view withAppstoreView:appStoreContainerView
                                         andPlaceHolder:placeHolder];
}

+ (void)requestCampaignCrossSelling:(void (^)(NSArray * campaignBannersVC))completion{
    [self requestCampaignCrossSellingWithPlaceHolder:nil onCompletion:completion error:nil];
}

+ (void)requestCampaignCrossSelling:(void (^)(NSArray * campaignBannersVC))completion error:(void (^)(NSString *errorMessage))error{
    [self requestCampaignCrossSellingWithPlaceHolder:nil onCompletion:completion error:error];
}

+ (void)requestCampaignCrossSellingWithPlaceHolder:(UIImage *)placeHolder
                                      onCompletion:(void (^)(NSArray *))completion
                                             error:(void (^)(NSString *))error {
    
    [[MCMCampaignsManager sharedInstance] requestBannersType:IN_APP_CROSS_SELLING
                                             withPlaceHolder:placeHolder
                                                  completion:completion error:nil];
}

+ (void)addCampaignPromotions:(UIView*)view{
    [self addCampaignPromotions:view withDelegate:nil];
}

+ (void)addCampaignPromotions:(UIView *)view withDelegate:(id<MCMCampaignsManagerDelegate>)delegate {
	
	[self addCampaignPromotions:view withDelegate:delegate andPlaceHolder:nil];
}

+ (void)addCampaignPromotions:(UIView*)view withDelegate:(id)delegate andPlaceHolder:(UIImage *)placeHolder{
    
    [[MCMCampaignsManager sharedInstance] addBannerType:IN_APP_PROMOTION inView:view withAppstoreView:nil andPlaceHolder:placeHolder];
    
    if(delegate != nil){
        [[MCMCampaignsManager sharedInstance] setDelegate:delegate];
    }
}

+ (void)removeCampaignBanner{
    
    [[MCMCampaignsManager sharedInstance] removeCurrentBanner];
}

+(void)setCampaignDuration:(int)duration{
    
    [[MCMCampaignsManager sharedInstance] setDuration:duration];
}

+ (void)requestCampaignPromotions:(void (^)(NSArray * campaignBannersVC))completion{
    [self requestCampaignPromotionsWithPlaceHolder:nil onCompletion:completion error:nil];
}

+ (void)requestCampaignPromotions:(void (^)(NSArray *))completion error:(void (^)(NSString *))error{
    [self requestCampaignPromotionsWithPlaceHolder:nil onCompletion:completion error:error];
}

+ (void)requestCampaignPromotionsWithPlaceHolder:(UIImage *)placeHolder
                                      onCompletion:(void (^)(NSArray *))completion
                                             error:(void (^)(NSString *))error {
    [[MCMCampaignsManager sharedInstance] requestBannersType:IN_APP_PROMOTION withPlaceHolder:placeHolder completion:completion error:error];
}

+ (void)addCampaignRateMyAppWithDelegate:(id<MCMCampaignsManagerDelegate>)delegate{
    [self addCampaignRateMyAppWithDelegate:delegate andAppstoreContainerView:nil];
}

+ (void)addCampaignRateMyAppWithDelegate:(id<MCMCampaignsManagerDelegate>)delegate andAppstoreContainerView:(UIView *)appStoreContainerView {
    [[MCMCampaignsManager sharedInstance] addBannerType:IN_APP_RATE_MY_APP inView:nil withAppstoreView:appStoreContainerView andPlaceHolder:nil];
    
    if(delegate != nil){
        [[MCMCampaignsManager sharedInstance] setDelegate:delegate];
    }
    
}


#pragma mark UIAlertViewDelegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"_____________alertView");
    
    if (buttonIndex==1){
        
        NSDictionary *pushDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:@"mcm_push_dictionary"];
        
        [MCMNotificationManager processRemoteNotification:pushDictionary];
    }
    
}

@end
