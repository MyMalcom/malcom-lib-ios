
#import <Foundation/Foundation.h>
#import "MCMModuleAdapter.h"

/**
 Module adapter used by the MCMNotifications module. It receives the notification events to register
 and open received notifications
 @since 1.0
 */
@interface MCMNotificationsAdapter : MCMModuleAdapter {
    NSDictionary *pushDictionary_;
    BOOL appActive_;
}

@end
