
#import <Foundation/Foundation.h>

@class MCMConfigSplashViewController;

@protocol MCMConfigApplicationDelegate <NSObject>

@optional
/**
 Implement this method if you want to be notified when the splash screen is
 going to be displayed
 @param splashViewController Splash View Controller to be displayed
 @returns void
 @since 1.0
 */
- (void) splashLoaded:(MCMConfigSplashViewController *)splashViewController;

/**
 Implement this method if you want to be notified when the splash screen has been removed
 @param splashViewController Splash View Controller removed
 @returns void
 @since 1.0
 */
- (void) splashUnloaded:(MCMConfigSplashViewController *)splashViewController;

@end
