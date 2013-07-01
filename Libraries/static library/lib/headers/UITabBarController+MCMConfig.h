#import <UIKit/UIKit.h>

/**
 Category additions for the UITabBarController. It brings new funcionality to this standard component
 in order to make the use of the library easier.
 @since 1.0
*/
@interface UITabBarController(MCMConfig)

/**
 Create the controllers for the sections defined in Malcom and loads them inside UINavigationController
 classes into the tabBar. 
 @since 1.0
*/
- (void) loadViewControllersFromMCMConfig;

@end
