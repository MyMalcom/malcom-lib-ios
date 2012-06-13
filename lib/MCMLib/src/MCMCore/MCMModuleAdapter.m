
#import "MCMModuleAdapter.h"

@implementation MCMModuleAdapter

+ (BOOL) moduleShouldAutoload{
    return YES;
}

//Application messages

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{}
- (void)applicationWillResignActive:(UIApplication *)application{}
- (void)applicationDidEnterBackground:(UIApplication *)application{}
- (void)applicationWillEnterForeground:(UIApplication *)application{}
- (void)applicationDidBecomeActive:(UIApplication *)application{}
- (void)applicationWillTerminate:(UIApplication *)application{}
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken{}
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err{}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{}

//UIViewController messages

- (void)viewDidLoad:(UIViewController*)vc{}
- (void)viewDidUnload:(UIViewController *)vc{}
- (void)viewAppear:(UIViewController *)vc{}
- (void)viewDisappear:(UIViewController *)vc{}
- (void)viewRotate:(UIViewController *)vc toOrientation:(UIInterfaceOrientation)orientation{}

//DEPRECATED
- (void)viewWillAppear:(BOOL)animated vc:(UIViewController *)vc{}
- (void)viewDidAppear:(BOOL)animated vc:(UIViewController *)vc{}
- (void)viewWillDisappear:(BOOL)animated vc:(UIViewController *)vc{}
- (void)viewDidDisappear:(BOOL)animated vc:(UIViewController *)vc{}

@end
