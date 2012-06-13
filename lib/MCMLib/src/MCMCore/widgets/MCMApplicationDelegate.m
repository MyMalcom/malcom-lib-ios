
#import "MCMApplicationDelegate.h"
#import "MCMLib.h"

@implementation MCMApplicationDelegate


@synthesize window=window_;
@synthesize tabBarController= tabBarController_;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    //Check Window exists
    if (self.window==nil){
        self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    }
    
    //Make window visible
    [self.window makeKeyAndVisible];
	    
    //Init MCMCore
    [[MCMCoreManager sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[MCMCoreManager sharedInstance] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[MCMCoreManager sharedInstance] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[MCMCoreManager sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[MCMCoreManager sharedInstance] applicationDidBecomeActive:application];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[MCMCoreManager sharedInstance] applicationWillTerminate:application];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[MCMCoreManager sharedInstance] applicationDidReceiveMemoryWarning:application];
}


- (void)dealloc {	
	self.window = nil;
	self.tabBarController=nil;    
    [super dealloc];
}



#pragma mark -
#pragma mark Delegation methods for APNS


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {    
    [[MCMCoreManager sharedInstance] application:app didRegisterForRemoteNotificationsWithDeviceToken:devToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {		
    [[MCMCoreManager sharedInstance] application:app didFailToRegisterForRemoteNotificationsWithError:err];
}

// This method is called if a push notification is recived while the application is running
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {	
    [[MCMCoreManager sharedInstance] application:application didReceiveRemoteNotification:userInfo];    
}


@end
