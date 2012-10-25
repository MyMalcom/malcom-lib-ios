

#pragma mark -
#pragma mark - Defines

#import "MCMNotificationUtils.h"


#define kMCMNotificationsAPIPath @"v2/apns/"
#define kMCMNotificationsAPIPathSandbox @"v2-SANDBOX/apns/"

#define kMCMNotificationsRegisterURI(appId) [NSString stringWithFormat:@"applications/%@/devices/%@", appId, [MCMCoreUtils uniqueIdentifier]]
#define kMCMNotificationsEfficacyURI(notId) [NSString stringWithFormat:@"notifications/%d/devices/%@", notId, [MCMCoreUtils uniqueIdentifier]]

#define kMCMNotificationRegisterURL @"v3/notification/registry/application"
#define kMCMNotificationACKURL @"v3/notification/ack/"

#define kMCMNotificationsTagDelimiter @"@"
#define kMCMNotificationsTagSeparator @" "
