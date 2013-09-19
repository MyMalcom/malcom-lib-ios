//
//  MalcomLib.h
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 19/04/12.
//  Copyright (c) 2012 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>
#import <CoreLocation/CoreLocation.h>
#import "MCMLib.h"
#import "MCMCampaignsManagerDelegate.h"

/**
 Class that manages the methods of Malcom Library. It's responsable of all Malcom's modules: 
 CORE, CONFIGURATION, STATS and NOTIFICATIONS
 @since 2.0.0
 */

@interface MalcomLib : NSObject


//  CORE
/**
 Init Malcom with app values
 @param uuid uuid malcom app
 @param secretKey secret key malcom app
 @since 2.0.3
 */
+ (void)initWithUUID:(NSString *)uuid andSecretKey:(NSString *)secretKey;

/**
 Init Malcom with app values
 @param uuid uuid malcom app
 @param secretKey secret key malcom app
 @param adId ads id Malcom
 @since 2.0.0
 */
+ (void)initWithUUID:(NSString *)uuid andSecretKey:(NSString *)secretKey withAdId:(NSString *)adId;

/**
 Init Malcom with app values
 @param uuid uuid malcom app
 @param secretKey secret key malcom app
 @param adId ads id Malcom
 @param logActivated BOOL param which show log if YES
 @since 2.0.0
 */
+ (void)initWithUUID:(NSString *)uuid andSecretKey:(NSString *)secretKey withAdId:(NSString *)adId andLogActivated:(BOOL)logActivated;

/**
 Init Malcom with app values and url api
 @param uuid uuid malcom app
 @param secretKey secret key malcom app
 @param adId ads id Malcom
 @param urlApi url api malcom
 @param logActivated BOOL param which show log if YES
 @since 2.0.0
 */
+ (void)initWithUUID:(NSString *)uuid andSecretKey:(NSString *)secretKey withAdId:(NSString *)adId urlApi:(NSString *)urlApi andLogActivated:(BOOL)logActivated;

/**
 Show log if param is YES
  @param logActivated BOOL param which show log if YES
 @since 2.0.0
 */
+ (void)showLog:(BOOL)logActivated;

/**
 Get Malcom udid
 return get malcom udid from device
 @since 2.0.0
 */
+ (NSString *)getUDID;

+ (NSString *)getMalcomID;

//  CONFIGURATION

/**
 Load Malcom configuration
 @param viewController viewController where load configuration
 @param delegate delegate from configuration
 @param isLabel BOOL value which indicate if label is showing or not
 @since 2.0.0
 */
+ (void)loadConfiguration:(UIViewController *)viewController withDelegate:(id)delegate withLabel:(BOOL) isLabel;

/**
 Load Malcom configuration
 @param viewController viewController where load configuration
 @param delegate delegate from configuration
 @param isSplash BOOL value which indicate if splash is showing or not
 @since 2.0.0
 */
+ (void)loadConfiguration:(UIViewController *)viewController withDelegate:(id)delegate withSplash:(BOOL) isSplash;

/**
 Get a advanced value from Malcom
 @param key Malcom value key
 @param vDefault value by default
 return key value
 @since 2.0.0
 */
+ (NSString *)getAdvanceConfigurationForKey:(NSString *)key valueDefault:(NSString *)vDefault;

/**
 Get sdk version
 @since 2.0.1
 */

+ (NSString *)sdkVersion;

//  STATS


/**
 Init and start stats in application and the use of wifi only is deactivated by default. If you want to use only wifi you should use the method initAndStartBeacon:useOnlyWiFi:
 @param userLocation BOOL value is YES if user location is activated
 @since 2.0.0
 */
+ (void)initAndStartBeacon:(BOOL)userLocation;
+ (void)initAndStartBeacon;

/**
 Resume malcon from background
 */
+ (void)resumeMalcom;

/**
 Init and start stats in application
 @param userLocation BOOL value is YES if user location is activated
 @param wifiState BOOL value is YES if only send stats when is connecting by wifi
 @since 2.0.0
 */
+ (void)initAndStartBeacon:(BOOL)userLocation useOnlyWiFi:(BOOL)wifiState __attribute__((deprecated("use initAndStartBeacon instead")));

/**
 End stats and send beacons to Malcom
 @since 2.0.0
 */
+ (void)endBeacon;

/**
 Start stats for a viewController or action
 @param action's name
 @since 2.0.0
 */
+ (void)startBeaconWithName:(NSString *)name;

/**
 End stats for a viewController or action adding params
 @param action's name
 @param params attributes
 @param timeSession if the user wants to track the time that subbeacon takes
 @since 2.0.2
 */
+ (void)startBeaconWithName:(NSString *)name andParams: (NSDictionary *) params andTimeSession: (BOOL)timeSession;

/**
 End stats for a viewController or action
 @param action's name
 @since 2.0.0
 */
+ (void)endBeaconWithName:(NSString *)name;

/**
 End stats for a viewController or action adding params
 @param action's name
 @param params attributes
 @since 2.0.2
 */
+ (void)endBeaconWithName:(NSString *)name andParams: (NSDictionary *) params;

/**
 Method that configures an user as identifier of the application
 @param mail
 @param name
 @since 2.0.2
 */
+ (void)identifyUserWithName: (NSString *) name mail: (NSString *) mail;

/**
 Method that configures an user as identifier of the application
 @param mail
 @param name
 @param params additional info in case it's needed
 @since 2.0.2
 */
+ (void)identifyUserWithName: (NSString *) name mail: (NSString *) mail andParams: (NSDictionary *) params;

/**
 Method that registers a revenue
 @param name revenue name
 @param sku purchase product code
 @param unitary price of the revenue
 @param currencyCode international code for currency (EUR, USD...)
 @param amount total amount of purchases
 @since 2.0.2
 */
+ (void)registerRevenueWithName: (NSString *)name SKU: (NSString *)SKU price: (float)price currencyCode: (NSString *)currency andAmount: (int)amount;

/**
 Method that tracks a view.
 @param name name of the view.
 @since 2.0.2
 */
+ (void)trackView: (NSString *)name;

/**
 Add tags to beacon
 @param tags
 @since 2.0.0
 */
+ (void)setTags:(NSArray *)tags __attribute__((deprecated("use addTag(NSString *tagName) instead")));

/**
 Get tags
 return tags
 @since 2.0.0
 */
+ (NSArray *)getTags;

/**
 Adds single tag to tags array
 @param tagName
 @since 2.0.3
 */
+ (void)addTag:(NSString *)tagName;

/**
 Removes single tag from tags array
 @param tagName
 @since 2.0.3
 */
+ (void)removeTag:(NSString *)tagName;

/**
 Clears the tags array
 @param tagName
 @since 2.0.3
 */
+ (void)removeAllTags;

/**
 Get location
 return location User Location
 @since 2.0.0
 */
+ (CLLocation *) getLocation;

/**
 Add user metadata to beacon
 @param userMetadata
 @since 2.0.1
 */
+ (void) setUserMetadata:(NSString *)userMetadata;

/**
 Get location
 return location User Location
 @since 2.0.0
 */
+ (NSString *) getUserMetadata;

//  Notifications

/**
 Prepare and start notifications on the application
 @param application UIApplication from didFinishLaunchingWithOptions
 @param launchOptions info about options and notifications
 @param developmentMode Enviroment where app is compile. debug = YES -> sandbox. debug = NO -> production 
 @since 2.0.0
 */
+ (void)startNotifications:(UIApplication *)application withOptions:(NSDictionary *)launchOptions isDevelopmentMode:(BOOL)developmentMode;

/**
 Prepare and start notifications on the application with developmentMode off by default
 @param application UIApplication from didFinishLaunchingWithOptions
 @param launchOptions info about options and notifications
 @since 3.0.0
 */
+ (void)startNotifications:(UIApplication *)application withOptions:(NSDictionary *)launchOptions;

/**
 Registre divice with token
 @param devToken Device token
 @since 2.0.0
 */
+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken;

/**
 Method has been notified that an error
 @param err Error
 @since 2.0.0
 */
+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)err;

/**
 Method has been notified that notification has been sent
 @param userInfo User Info
 @param appActive Param indicating ecl the application is active or not
 @since 2.0.0
 */
+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo active:(BOOL)appActive;

/**
 Method set if app is active
 @param active YES if app is active
 @since 2.0.0
 */
+ (void)setAppActive:(BOOL)active;
+ (void)setAppActive;
+ (void)setAppInactive;

/**
 Method get if app is active
 @return appActive Param indicating if app is active
 @since 2.0.0
 */
+ (BOOL)getAppActive;


//  Campaings

/**
 Method that enables the campaigns banner retrieved from server and places it on the window. Duration by default is 15 seconds. Time can be setted with setCampaignDuration:.
 @param view UIView where is going to be placed the banner. If the server sends fullscreen or middle type it will be placed above the window (not the specified view) in order to get the fullscreen or middle visualization. Otherwise it will be placed only in this view, so the logic thing is to send here the whole view of the viewcontroller to achieve the correct position of the banner sent from server (top, bottom).
 @since 2.0.0
 */
+ (void)addCampaignBanner:(UIView*)view __attribute__((deprecated("use addCampaign_type method instead")));

/**
 Method that enables the campaigns banner retrieved from server and places it on the window. Duration by default is 15 seconds. Time can be setted with setCampaignDuration:.
 @param view UIView where is going to be placed the banner. If the server sends fullscreen or middle type it will be placed above the window (not the specified view) in order to get the fullscreen or middle visualization. Otherwise it will be placed only in this view, so the logic thing is to send here the whole view of the viewcontroller to achieve the correct position of the banner sent from server (top, bottom).
 @param id delegate for controlling the banner finishing, loading and failing
 @since 2.0.0
 */
+ (void)addCampaignBanner:(UIView*)view withDelegate:(id<MCMCampaignsManagerDelegate>)delegate __attribute__((deprecated("use addCampaign_type method instead")));

/**
 Method that enables the campaigns banner retrieved from server and places it on the window. Duration by default is 15 seconds. Time can be setted with setCampaignDuration:.
 @param view UIView where is going to be placed the banner. If the server sends fullscreen or middle type it will be placed above the window (not the specified view) in order to get the fullscreen or middle visualization. Otherwise it will be placed only in this view, so the logic thing is to send here the whole view of the viewcontroller to achieve the correct position of the banner sent from server (top, bottom).
 @param appStoreContainerView View where user wants to present the Appstore.
 @since 2.0.0
 */
+ (void)addCampaignBanner:(UIView*)view withAppstoreContainerView:(UIView*)appStoreContainerView __attribute__((deprecated("use addCampaign_type method instead")));

/**
 Method that enables the campaigns banner retrieved from server and places it on the window. Duration by default is 15 seconds. Time can be setted with setCampaignDuration:.
 @param view UIView where is going to be placed the banner. If the server sends fullscreen or middle type it will be placed above the window (not the specified view) in order to get the fullscreen or middle visualization. Otherwise it will be placed only in this view, so the logic thing is to send here the whole view of the viewcontroller to achieve the correct position of the banner sent from server (top, bottom).
  @param id delegate for controlling the banner finishing, loading and failing
 @param appStoreContainerView View where user wants to present the Appstore.
 @since 2.0.0
 */
+ (void)addCampaignBanner:(UIView*)view withAppstoreContainerView:(UIView*)appStoreContainerView withDelegate:(id<MCMCampaignsManagerDelegate>)delegate __attribute__((deprecated("use addCampaign_type method instead")));

//Multitype Campaigns

/**
 Method that enables the campaigns banner retrieved from server and places it on the window. Duration by default is 15 seconds. Time can be setted with setCampaignDuration:.
 @param view UIView where is going to be placed the banner. If the server sends fullscreen or middle type it will be placed above the window (not the specified view) in order to get the fullscreen or middle visualization. Otherwise it will be placed only in this view, so the logic thing is to send here the whole view of the viewcontroller to achieve the correct position of the banner sent from server (top, bottom).
 @since 2.0.1
 */
+ (void)addCampaignCrossSelling:(UIView*)view;

/**
 Method that enables the campaigns banner retrieved from server and places it on the window. Duration by default is 15 seconds. Time can be setted with setCampaignDuration:.
 @param view UIView where is going to be placed the banner. If the server sends fullscreen or middle type it will be placed above the window (not the specified view) in order to get the fullscreen or middle visualization. Otherwise it will be placed only in this view, so the logic thing is to send here the whole view of the viewcontroller to achieve the correct position of the banner sent from server (top, bottom).
 @param id delegate for controlling the banner finishing, loading and failing
 @since 2.0.1
 */
+ (void)addCampaignCrossSelling:(UIView*)view withDelegate:(id<MCMCampaignsManagerDelegate>)delegate;

/**
 Method that enables the campaigns banner retrieved from server and places it on the window. Duration by default is 15 seconds. Time can be setted with setCampaignDuration:.
 @param view UIView where is going to be placed the banner. If the server sends fullscreen or middle type it will be placed above the window (not the specified view) in order to get the fullscreen or middle visualization. Otherwise it will be placed only in this view, so the logic thing is to send here the whole view of the viewcontroller to achieve the correct position of the banner sent from server (top, bottom).
 @param appStoreContainerView View where user wants to present the Appstore.
 @since 2.0.1
 */
+ (void)addCampaignCrossSelling:(UIView*)view withAppstoreContainerView:(UIView*)appStoreContainerView;

/**
 Method that enables the campaigns banner retrieved from server and places it on the window. Duration by default is 15 seconds. Time can be setted with setCampaignDuration:.
 @param view UIView where is going to be placed the banner. If the server sends fullscreen or middle type it will be placed above the window (not the specified view) in order to get the fullscreen or middle visualization. Otherwise it will be placed only in this view, so the logic thing is to send here the whole view of the viewcontroller to achieve the correct position of the banner sent from server (top, bottom).
 @param id delegate for controlling the banner finishing, loading and failing
 @param appStoreContainerView View where user wants to present the Appstore.
 @since 2.0.1
 */

+ (void)addCampaignCrossSelling:(UIView*)view withAppstoreContainerView:(UIView*)appStoreContainerView withDelegate:(id<MCMCampaignsManagerDelegate>)delegate;
+ (void)addCampaignCrossSelling:(UIView*)view withAppstoreContainerView:(UIView*)appStoreContainerView withDelegate:(id<MCMCampaignsManagerDelegate>)delegate andPlaceHolder:(UIImage *)placeHolder;

/**
 Method that request the available campaign banners from server and creates an array with the banners view controller.
 @param ^completion block that will be executed when the proccess will finnish
 @since 2.0.1
 */
+ (void)requestCampaignCrossSelling:(void (^)(NSArray * campaignBannersVC))completion;

/**
 Method that request the available campaign banners from server and creates an array with the banners view controller.
 @param ^completion block that will be executed when the proccess will finnish
 @param ^error block that will be executed when an error occurs
 @since 2.0.1
 */
+ (void)requestCampaignCrossSelling:(void (^)(NSArray * campaignBannersVC))completion error:(void (^)(NSString *errorMessage))error;
+ (void)requestCampaignCrossSellingWithPlaceHolder:(UIImage *)placeHolder
                                      onCompletion:(void (^)(NSArray * campaignBannersVC))completion
                                             error:(void (^)(NSString *errorMessage))error;

/**
 Method that enables the campaigns banners retrieved from server and places it on the view.
 @param view UIView where is going to be placed the list of banners.
 @since 2.0.1
 */
+ (void)addCampaignPromotions:(UIView *)view;

/**
 Method that enables the campaigns banners retrieved from server and places it on the view.
 @param view UIView where is going to be placed the list of banners.
 @param id delegate for controlling the banner finishing, loading, failing and press
 @since 2.0.1
 */
+ (void)addCampaignPromotions:(UIView *)view withDelegate:(id<MCMCampaignsManagerDelegate>)delegate;
+ (void)addCampaignPromotions:(UIView *)view withDelegate:(id<MCMCampaignsManagerDelegate>)delegate andPlaceHolder:(UIImage *)placeHolder;

/**
 Method that disables the campaigns banner retrieved from server and removes the current one.
 @since 2.0.0
 */
+ (void)removeCampaignBanner;

/** 
 Method that sets the duration for the campaign showing. By default it will 15 seconds.
 @param duration int with duration in seconds. Value zero means that it wont dissapear never. By default it will dissapear at 15 seconds.
 @since 2.0.0
 */
+ (void)setCampaignDuration:(int)duration;

/**
 Method that request the available campaign banners from server and creates an array with the banners view controller.
 @param ^completion block that will be executed when the proccess will finnish
 @since 2.0.1
 */
+ (void)requestCampaignPromotions:(void (^)(NSArray * campaignBannersVC))completion;
+ (void)requestCampaignPromotionsWithPlaceHolder:(UIImage *)placeHolder
                                    onCompletion:(void (^)(NSArray * campaignBannersVC))completion;

/**
 Method that request the available campaign banners from server and creates an array with the banners view controller.
 @param ^completion block that will be executed when the proccess will finnish
 @param ^error block that will be executed when an error occurs
 @since 2.0.1
 */
+ (void)requestCampaignPromotions:(void (^)(NSArray * campaignBannersVC))completion error:(void (^)(NSString *errorMessage))error;
+ (void)requestCampaignPromotionsWithPlaceHolder:(UIImage *)placeHolder
                                    onCompletion:(void (^)(NSArray * campaignBannersVC))completion
                                           error:(void (^)(NSString *errorMessage))error;

/**
 Method that shows an alert for rate the app based on configured parameters on malcom server.
 @param delegate Delegate with methods to be called for campaign control.
 @since 2.0.3
 */
+ (void)addCampaignRateMyAppWithDelegate:(id<MCMCampaignsManagerDelegate>)delegate;

/**
 Method that shows an alert for rate the app based on configured parameters on malcom server.
 @param delegate Delegate with methods to be called for campaign control.
 @param appStoreContainerView View where the appstore will be shown.
 @since 2.0.3
 */
+ (void)addCampaignRateMyAppWithDelegate:(id<MCMCampaignsManagerDelegate>)delegate andAppstoreContainerView:(UIView *)appStoreContainerView;

@end
