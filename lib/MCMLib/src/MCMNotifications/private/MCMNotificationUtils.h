
#import <Foundation/Foundation.h>

/**
 Utilities class used by other MCMNotification module classes. It's used for specific utilities
 within the Notifications module
 @since 1.0
 */
@interface MCMNotificationUtils : NSObject {
    
}

/**
 Transforms an array of tags to the correct formatted string for Mobivery's Push Notification Service
 @param tags Array of tags to register in Apns
 @return string of tags correctly formatted (format: @atag@ @anothertag@ @adiferenttag@)
 */
+ (NSString *) formatApnsTagString: (NSArray *) tags;

@end
