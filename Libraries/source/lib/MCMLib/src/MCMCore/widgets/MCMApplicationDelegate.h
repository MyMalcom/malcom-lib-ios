
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 UIApplicationDelegate based class preprared to bypass all the events related to
 the UIApplicationDelegate
 @since 1.0
 */
@interface MCMApplicationDelegate : UIResponder<UIApplicationDelegate> {
}

/**
 IBOutlet for the main window of the application. 
 @since 1.0
 */
@property (nonatomic, retain) IBOutlet UIWindow *window;

/**
 IBOutlet for the tabbar used by the application. It's created automatically when MCMConfigModule active and
 no tabbar existis
 @since 1.0
 */
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
