
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 Base class used by the rest of module adapters. By default, this class make nothing with the events
 @since 1.0
 */
@interface MCMModuleAdapter : NSObject {}

+ (BOOL) moduleShouldAutoload;

//Application messages

/**
 UIApplicationDelegate receiver for didFinishLaunchingWithOptions
 @since 1.0
 */
- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
/**
 UIApplicationDelegate receiver for applicationWillResignActive
 @since 1.0
 */
- (void)applicationWillResignActive:(UIApplication *)application;
/**
 UIApplicationDelegate receiver for applicationDidEnterBackground
 @since 1.0
 */
- (void)applicationDidEnterBackground:(UIApplication *)application;
/**
 UIApplicationDelegate receiver for applicationWillEnterForeground
 @since 1.0
 */
- (void)applicationWillEnterForeground:(UIApplication *)application;
/**
 UIApplicationDelegate receiver for applicationDidBecomeActive
 @since 1.0
 */
- (void)applicationDidBecomeActive:(UIApplication *)application;
/**
 UIApplicationDelegate receiver for applicationWillTerminate
 @since 1.0
 */
- (void)applicationWillTerminate:(UIApplication *)application;
/**
 UIApplicationDelegate receiver for didRegisterForRemoteNotificationsWithDeviceToken
 @since 1.0
 */
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken;
/**
 UIApplicationDelegate receiver for didFailToRegisterForRemoteNotificationsWithError
 @since 1.0
 */
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err;
/**
 UIApplicationDelegate receiver for didReceiveRemoteNotification
 @since 1.0
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
/**
 UIApplicationDelegate receiver for applicationDidReceiveMemoryWarning
 @since 1.0
 */
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;


//UIViewController messages

/**
 UIViewController receiver for viewDidLoad event
 @since 1.0
 */
- (void)viewDidLoad:(UIViewController*)vc;

/**
 UIViewController receiver for viewDidUnload event
 @since 1.0
 */
- (void)viewDidUnload:(UIViewController *)vc;

/**
 UIViewController receiver for viewWillAppear event
 @since 1.1.0
 */
- (void)viewAppear:(UIViewController *)vc;

/**
 UIViewController receiver for viewWillAppear event
 @since 1.1.0
 */
- (void)viewDisappear:(UIViewController *)vc;

/**
 UIViewController receiver for rotation events
 @since 1.1.0
 */
- (void)viewRotate:(UIViewController *)vc toOrientation:(UIInterfaceOrientation)orientation;

@end

//DEPRECATED
@interface MCMModuleAdapter(deprecated)

/**
 UIViewController receiver for viewWillAppear event
 @since 1.0
 @deprecated use viewAppear instead
 @see viewAppear
 */
- (void)viewWillAppear:(BOOL)animated vc:(UIViewController *)vc;
/**
 UIViewController receiver for viewDidAppear event
 @deprecated method no longer needed if you call to viewAppear
 @since 1.0
 @see viewAppear
 */
- (void)viewDidAppear:(BOOL)animated vc:(UIViewController *)vc;
/**
 UIViewController receiver for viewWillDisappear event
 @since 1.0
 @deprecated use viewDisappear instead
 @see viewDisappear
 */
- (void)viewWillDisappear:(BOOL)animated vc:(UIViewController *)vc;
/**
 UIViewController receiver for viewDidDisappear event
 @since 1.0
 @deprecated method no longer needed if you call to viewDisappear
 @see viewDisappear
 */
- (void)viewDidDisappear:(BOOL)animated vc:(UIViewController *)vc;


@end