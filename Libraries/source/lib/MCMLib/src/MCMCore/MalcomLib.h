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

//  STATS

/**
 Init and start stats in application
 @param userLocation BOOL value is YES if user location is activated
 @param wifiState BOOL value is YES if only send stats when is connecting by wifi
 @since 2.0.0
 */
+ (void)initAndStartBeacon:(BOOL)userLocation useOnlyWiFi:(BOOL)wifiState;

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
 End stats for a viewController or action
 @param action's name
 @since 2.0.0
 */
+ (void)endBeaconWithName:(NSString *)name;

/**
 Add tags to beacon
 @param tags
 @since 2.0.0
 */
+ (void)setTags:(NSArray *)tags;

/**
 Get tags
 return tags
 @since 2.0.0
 */
+ (NSArray *) getTags;

/**
 Get location
 return location User Location
 @since 2.0.0
 */
+ (CLLocation *) getLocation;

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
    
@end
