
#import <Foundation/Foundation.h>


@protocol MCMNotificationsApplicationDelegate <NSObject>

/**
 Implement this method if you want to customize the action when an APNS is received
 @param userInfo Dictionary with the received information from the APNS
 @returns void
 @since 1.0
 */
- (void) processRemoteNotification:(NSDictionary *)userInfo;

@end
