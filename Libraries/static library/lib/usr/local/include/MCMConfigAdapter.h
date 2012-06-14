
#import <Foundation/Foundation.h>
#import "MCMModuleAdapter.h"
#import "MCMConfigSplashViewController.h"

/**
 Module adapter used by the MCMConfig module. It inits MCMConfigManager and manages the splash screen
 @since 1.0
 */
@interface MCMConfigAdapter : MCMModuleAdapter {
    BOOL splashLoaded_;
    MCMConfigSplashViewController *splashController_;
    UITabBarController *tabBarController_;
}

@end
