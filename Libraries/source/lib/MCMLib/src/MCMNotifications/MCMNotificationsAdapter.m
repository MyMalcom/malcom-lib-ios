
#import "MCMNotificationsAdapter.h"
#import "MCMNotifications.h"
#import "MCMCoreDefines.h"
#import "MCMCore.h"

@implementation MCMNotificationsAdapter

- (void) dealloc{
    [pushDictionary_ release]; pushDictionary_=nil;    
    [super dealloc];
}

- (void)applicationWillResignActive:(UIApplication *)application{ 
    appActive_=NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{ 
    appActive_=YES;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
      
    
    // Register the app in Apple APNS to use push notifications
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound | 
                                                         UIRemoteNotificationTypeAlert)];
        
         
     // Setting APNS badge to none initially
     application.applicationIconBadgeNumber = 0;
     
     //	Verifying if application was run in a normal way or was opened from a push notification
     if (launchOptions == nil) {
         //	Normal tasks if appication was run in a normal way
         // ...
         [MCMLog log:@"Malcom - MCMNotifications App running in normal mode" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
         
     } else {
         // Initialization task when app was run from a push notification
         
         [MCMLog log:[NSString stringWithFormat:@"Malcom - MCMNotifications App running from push notification with pushOption -> %@", [[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] description]] 
              inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];

         //Receive the notification
         [MCMNotificationManager didReceiveRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];

         //Process the notification
         [MCMNotificationManager processRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];

     }
          
}


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
	//	Calling method which registers the application in Malcom service.     
    if ([[MCMCoreManager sharedInstance] developmentMode]){            
        [MCMNotificationManager didRegisterForRemoteNotificationsInSANDBOX:devToken];   
    }
    else {
        [MCMNotificationManager didRegisterForRemoteNotificationsWithDeviceToken:devToken];
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {		
	//	Calling method that manages errors
	[MCMNotificationManager didFailToRegisterForRemoteNotificationsWithError:err];	    
}

// This method is called if a push notification is recived while the application is running
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Initialization task when app was run from a push notification
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom - MCMNotifications Push notification received while app running with pushOption -> %@", [userInfo description]] 
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
    //Receive the notification
	[MCMNotificationManager didReceiveRemoteNotification:userInfo];
    
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
    // Create an alert message sent in the push notification
    NSString *alertMsg=nil;
    if( [[userInfo objectForKey:@"aps"] objectForKey:@"alert"] != NULL) {
        alertMsg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]; 
    }
    
    if (([alertMsg length]>0) && (appActive_==YES)){
        [pushDictionary_ release];
        pushDictionary_ = [userInfo retain];
        
        // Showing an alert with push notification message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:alertMsg delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                              otherButtonTitles:NSLocalizedString(@"View", @""),nil];
        [alert show];
        [alert release];	
    }
    //If no alert found or app was inactive, process the message
    else{
        [MCMNotificationManager processRemoteNotification:userInfo];
    }
}

#pragma mark UIAlertViewDelegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex==1){
        [MCMNotificationManager processRemoteNotification:pushDictionary_];
    }
    
    [pushDictionary_ release]; pushDictionary_=nil;
}

@end
