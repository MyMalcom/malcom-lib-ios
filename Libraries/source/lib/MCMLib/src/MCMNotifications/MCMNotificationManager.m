
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

+ (void) didRegisterAPNS:(NSData*)devToken inServer:(NSString*)url withAppId:(NSString*)appId withTags:(NSArray *)tags{
	
	if ((url==nil) || (appId==nil) || (devToken==nil)){
        
        [MCMLog log:@"Mobivery APNS Library: Error in registration because of the parameters" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
		return ;
	}
    
    //Keep the devToken for future uses. Note: retain before release just in case is the same data
    [devToken retain];
    [sDevToken release];
    sDevToken = devToken;        
    
    //Compose the URL
    url = [url stringByAppendingString:kMCMNotificationsRegisterURI(appId)];    
	
    [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: url: %@", url] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    

    // Device token
	const unsigned *tokenBytes = [devToken bytes];
	NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
						  ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
						  ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
						  ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
	
    [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: deviceToken: %@", hexToken] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    // Language of device
	NSString *currentLanguage = [MCMCoreUtils currentLanguage];
    [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: language: %@", currentLanguage] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];

    
    // Country
    NSString *country = [MCMCoreUtils languageDeviceCountryCode];
    [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: country: %@",country] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    // Device Model
    NSString *deviceModel = [MCMCoreUtils machinePlatform];
    [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: deviceModel: %@",deviceModel] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    // Device OS
    NSString *deviceOS = [MCMCoreUtils systemVersion];
    [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: deviceOS: %@",deviceOS] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    // Application version
    NSString *version = [MCMCoreUtils applicationVersion];
    [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: version: %@",version] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];

    // Timezone
    NSString *timeZone = [MCMCoreUtils userTimezone];
    [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: timeZone: %@",timeZone] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    NSString *json = [NSString stringWithFormat:@"{\"apns_registration\":{\"application_code\":\"%@\",\"token\":\"%@\",\"language\":\"%@\",\"tags\":\%@\,\"country\":\"%@\",\"device_model\":\"%@\",\"device_os\":\"%@\",\"app_version\":\"%@\", \"time_zone\":\"%@\"}}",appId, hexToken, currentLanguage, [MCMNotificationUtils formatApnsTagString:tags], country, deviceModel, deviceOS, version, timeZone];
    
    [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: request: %@", json] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    // Malcom's PNS device registration request        
    MCMCoreAPIRequest *request = [[MCMCoreAPIRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request startAsynchronous];
	
}

+ (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)devToken {	
    NSArray *tags = [MCMNotificationManager getTags];
    
    NSString *url = [[MCMCoreManager sharedInstance] malcomUrlForPath:kMCMNotificationsAPIPath];
    
	[self didRegisterAPNS:devToken inServer:url withAppId:[[MCMCoreManager sharedInstance] malcomAppId] withTags:tags];	
}

+ (void) didRegisterForRemoteNotificationsInSANDBOX:(NSData*)devToken {
    NSArray *tags = [MCMNotificationManager getTags];
    
    NSString *url = [[MCMCoreManager sharedInstance] malcomUrlForPath:kMCMNotificationsAPIPathSandbox];
    
	[self didRegisterAPNS:devToken inServer:url withAppId:[[MCMCoreManager sharedInstance] malcomAppId] withTags:tags];	
}

+ (void) didFailToRegisterForRemoteNotificationsWithError: (NSError *) err{	
    
    [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: Error in registration: %@", err] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    [sDevToken release]; sDevToken=nil;
    
}

+ (void) didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: Notification received - %@", [userInfo description]] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
	    
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
                        
        NSString *url = nil;
        if ([[MCMCoreManager sharedInstance] developmentMode]){
            url = [[MCMCoreManager sharedInstance] malcomUrlForPath:kMCMNotificationsAPIPathSandbox];
        }
        else{
            url = [[MCMCoreManager sharedInstance] malcomUrlForPath:kMCMNotificationsAPIPath];
        }
        url = [url stringByAppendingString:kMCMNotificationsEfficacyURI(notificationId)];    
        
        NSString *timeStamp = [[NSDate date] description];
        NSString *json = [NSString stringWithFormat:@"{\"apns_efficacy\":{\"time_stamp\":\"%@\"}}", timeStamp];        
          
        [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: efficacy request: %@", json] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        
        MCMCoreAPIRequest *request = [[MCMCoreAPIRequest alloc] initWithURL:[NSURL URLWithString:url]];
        [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request startAsynchronous];
    }    
}


+ (void) processRemoteNotification:(NSDictionary *)userInfo{
    
	//Look for MALCOM custom parameters
	NSString *webUrl=[[userInfo objectForKey:kMCMNotificationsTagWeb] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([webUrl length]>0){
		
        [MCMLog log:[NSString stringWithFormat:@"Mobivery APNS Library: Open Web URL: %@", webUrl] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
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

@end
