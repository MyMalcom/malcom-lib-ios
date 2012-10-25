
#import <Foundation/Foundation.h>
#import "MCMASIHTTPRequestDelegate.h"

/**
 Class that manages the MCMNotification module. It's responsable of registering devices within the
 Malcom Server and managing the tags. It also handle the RichNotifications by opening a view controller
 designed for the notification
 @since 1.0
 */
@interface MCMNotificationManager : NSObject<MCMASIHTTPRequestDelegate> {
    
}

/**
 Return the token Id received for this device
 @returns token Id
 @since 1.0
 */
+ (NSData *) tokenId;

/**
 Associate a new set of tags with this device and perform the update on the server
 @param tags Array of new tags to be associated
 @returns void
 @since 1.0
 */
+ (void) setTags:(NSArray *)tags;

/**
 Return the associated tags for this device
 @returns Array of tags
 @since 1.0
 */
+ (NSArray *) getTags;

/**
 Registers the device in Mobivery`s Malcom Push Notifications Service (Production mode)
 @param devToken Device Token assigned by Apple to the device after registration in APNS
 @returns void
 @since 1.0
 */
+ (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)devToken;		

/**
 Registers the device in Mobivery`s Malcom Push Notifications Service (Sandbox mode)
 @param devToken Device Token assigned by Apple to the device after registration in APNS
 @returns void
 @since 1.0
 */
+ (void) didRegisterForRemoteNotificationsInSANDBOX:(NSData*)devToken;

/**
 Displays the exception due to an error ocurred during the register of the device in Apple Push Notification Service
 @param error error returned by Apple
 @returns void
 @since 1.0
 */
+ (void) didFailToRegisterForRemoteNotificationsWithError:(NSError*)err;


#pragma mark -
#pragma mark - APNS predefined receiving methods
/**
 Receive the APNS and send the ackward to Malcom
 @param userInfo Dictionary with the received information from the APNS
 @returns void
 @since 1.0
 */
+ (void) didReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 Process the APNS received trying to look for custom properties or checking for
 custom user methods in the application delegate
 @param userInfo Dictionary with the received information from the APNS
 @returns void
 @since 1.0
 */
+ (void) processRemoteNotification:(NSDictionary *)userInfo;



@end

