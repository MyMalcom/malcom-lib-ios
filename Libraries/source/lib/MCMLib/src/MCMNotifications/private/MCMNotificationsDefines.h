

#pragma mark -
#pragma mark - Defines

#import "MCMNotificationUtils.h"


#define kMCMNotificationsAPIPath @"v2/apns/"
#define kMCMNotificationsAPIPathSandbox @"v2-SANDBOX/apns/"

#define kMCMNotificationsRegisterURI(appId) [NSString stringWithFormat:@"applications/%@/devices/%@", appId, [MCMCoreUtils uniqueIdentifier]]
#define kMCMNotificationsEfficacyURI(notId) [NSString stringWithFormat:@"notifications/%d/devices/%@", notId, [MCMCoreUtils uniqueIdentifier]]

#define kMCMNotificationsTagDelimiter @"@"
#define kMCMNotificationsTagSeparator @" "
