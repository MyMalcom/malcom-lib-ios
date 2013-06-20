
#import "MCMNotificationManager.h"
#import "MCMNotificationsDefines.h"
#import "MCMNotifications.h"

#import "MCMCore.h"
#import "MCMCoreDefines.h"

@implementation MCMNotificationManager

static NSData *sDevToken=nil;


+ (NSData *) tokenId{
    return sDevToken;
}


+ (void) setTags:(NSArray *)tags{
	[[NSUserDefaults standardUserDefaults] setObject:tags forKey:@"apns_tags"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
    if (sDevToken){
        //	Calling method which registers the application in Malcom service.

        if ([[MCMCoreManager sharedInstance] developmentMode]){            
            [self didRegisterForRemoteNotificationsInSANDBOX:sDevToken];            
        }
        else{            
            [self didRegisterForRemoteNotificationsWithDeviceToken:sDevToken];            
        }
	}
}

+ (NSArray *) getTags{
	return [[NSUserDefaults standardUserDefaults] arrayForKey:@"apns_tags"];
}

+ (void) didRegisterAPNS:(NSData*)devToken inEnvironment:(NSString*)environment {
	
	if (devToken==nil || [[MCMCoreManager sharedInstance] malcomAppId] == nil){
        
        [MCMLog log:@"Malcom MCMNotifications - MCMNotificationManager Notification Library: Error in registration because of the parameters" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
		return ;
	}
    
    //Keep the devToken for future uses. Note: retain before release just in case is the same data
    [devToken retain];
    [sDevToken release];
    sDevToken = devToken;        
    
    //Compose the URL
	NSString *url = [[MCMCoreManager sharedInstance] malcomUrlForPath:kMCMNotificationRegisterURL];
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom MCMNotifications - MCMNotificationManager APNS Library: url: %@", url] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    

    // Device token
	const unsigned *tokenBytes = [devToken bytes];
	NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
						  ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
						  ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
						  ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
	
    [MCMLog log:[NSString stringWithFormat:@"Malcom MCMNotifications - MCMNotificationManager APNS Library: deviceToken: %@", hexToken] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    NSString *json = [NSString stringWithFormat:@"{\"NotificationRegistration\":{\"applicationCode\":\"%@\",\"environment\":\"%@\",\"token\":\"%@\",\"udid\":\"%@\",\"devicePlatform\":\"%@\"}}",[[MCMCoreManager sharedInstance] malcomAppId], environment, hexToken, [MCMCoreUtils uniqueIdentifier], @"IOS"];
    
    IF_IOS6_OR_GREATER(
                       json = [NSString stringWithFormat:@"{\"NotificationRegistration\":{\"applicationCode\":\"%@\",\"environment\":\"%@\",\"token\":\"%@\",\"udid\":\"%@\",\"identifier\":\"%@\",\"devicePlatform\":\"%@\"}}",[[MCMCoreManager sharedInstance] malcomAppId], environment, hexToken, [MCMCoreUtils uniqueIdentifier], [MCMCoreUtils deviceIdentifier], @"IOS"];
                       )
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom MCMNotifications - MCMNotificationManager APNS Library: request: %@", json] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    // Malcom's PNS device registration request        
    MCMCoreAPIRequest *request = [[MCMCoreAPIRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setDelegate:self];
    [request startAsynchronous];
    
	
}

+ (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)devToken {
    
	[self didRegisterAPNS:devToken inEnvironment:@"PRODUCTION"];
    
}

+ (void) didRegisterForRemoteNotificationsInSANDBOX:(NSData*)devToken {
    
	[self didRegisterAPNS:devToken inEnvironment:@"SANDBOX"];
}

+ (void) didFailToRegisterForRemoteNotificationsWithError: (NSError *) err{	
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom MCMNotifications - MCMNotificationManager APNS Library: Error in registration: %@", err] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    [sDevToken release]; sDevToken=nil;
    
}

+ (void) didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom MCMNotifications - MCMNotificationManager APNS Library: Notification received - %@", userInfo] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
	    
    NSInteger notificationId=0;
    
    //Check the notificationId to send the notification awkward for efficiency
    id notId = [userInfo objectForKey:kMCMNotificationsTagId];
    if ([notId isKindOfClass:[NSString class]]){
        notificationId=[notId longLongValue];
    }
    else if ([notId isKindOfClass:[NSDecimalNumber class]]){
        notificationId=[notId doubleValue];
    }
    
    // Malcom's APNS device efficacy request
    if (notificationId>0){        
                        
        NSString *url = [[MCMCoreManager sharedInstance] malcomUrlForPath:kMCMNotificationACKURL];
        
        NSString *timeStamp = [[NSDate date] description];
        
        NSString *segmentId = [userInfo objectForKey:kMCMNotificationsSegmentId];
        
        if (segmentId == nil) {
            
            segmentId = @"0";
            
        }
        
        NSString *environment = @"";
        
        if ([[MCMCoreManager sharedInstance ]developmentMode]) {
            
            environment = @"SANDBOX";
            
        }
        else {
            
            environment = @"PRODUCTION";
            
        }
        
        NSString *json = [NSString stringWithFormat:@"{\"notificationReceipt\":{\"created\":\"%@\",\"applicationCode\":\"%@\",\"environment\":\"%@\",\"id\":\"%d\",\"udid\":\"%@\", \"segmentId\":\"%@\"}}", timeStamp, [[MCMCoreManager sharedInstance] malcomAppId], environment, notificationId, [MCMCoreUtils uniqueIdentifier],segmentId];
        
        IF_IOS6_OR_GREATER(
                           json = [NSString stringWithFormat:@"{\"notificationReceipt\":{\"created\":\"%@\",\"applicationCode\":\"%@\",\"environment\":\"%@\",\"id\":\"%d\",\"udid\":\"%@\",\"identifier\":\"%@\",\"segmentId\":\"%@\"}}", timeStamp, [[MCMCoreManager sharedInstance] malcomAppId], environment, notificationId, [MCMCoreUtils uniqueIdentifier],[MCMCoreUtils deviceIdentifier],segmentId];
                           )
          
        [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: efficacy request: %@", json] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        
        MCMCoreAPIRequest *request = [[MCMCoreAPIRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.delegate = self;
        [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request startAsynchronous];
        
//        NSError *error = [request error];
//        
//        NSLog(@"________Error: %@", error);
//        
//        if ((!error) && ([request responseStatusCode]<402)) {
//            
//            [MCMLog log:[NSString stringWithFormat:@"Success registry: %d", [request responseStatusCode]] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
//            
//        }
//        else {
//            
//            [MCMLog log:[NSString stringWithFormat:@"Error registry: %@", [request responseStatusMessage]] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
//        }
        
    }    
}


+ (void) processRemoteNotification:(NSDictionary *)userInfo{
    
	//Look for MALCOM custom parameters
	NSString *webUrl=[[userInfo objectForKey:kMCMNotificationsTagWeb] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([webUrl length]>0){
		
        [MCMLog log:[NSString stringWithFormat:@"Malcom MCMNotifications - MCMNotificationManager APNS Library: Open Web URL: %@", webUrl] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
		MCMCoreWebAlertView *webViewController = [[MCMCoreWebAlertView alloc] init];
		[webViewController setUrl:[NSURL URLWithString:webUrl]];
		[webViewController show];
		[webViewController release];
        return;
	}
    
    //If none custom, look for user actions defined in the UIApplicationDelegate
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(processRemoteNotification:)]){
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(processRemoteNotification:) withObject:userInfo];
    }    
}

- (void)requestFinished:(MCMASIHTTPRequest *)request {

    NSLog(@"requestFinished");

}


- (void)requestFailed:(MCMASIHTTPRequest *)request {

    NSLog(@"requestFailed");

}

@end
