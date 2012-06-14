
#import <UIKit/UIKit.h>

@class MCMConfigSplashViewController;

/**
 Delegate used by the MCMConfigSplashViewController class
 @since 1.0
*/
@protocol MCMConfigSplashDelegate

@optional

/**
 Delegate method to notify the disappear event. It's called just before removing the 
 splash screen and ask if it should disappear to the delegate. Note that if you 
 return NO it should be removed manually by calling [removeSplash] when done
 @param splashViewController Splash controller that is going to be removed
 @since 1.0
*/
- (BOOL) splashShouldDisappear:(MCMConfigSplashViewController *)splashViewController;

@end


/**
 UIViewController subclass for including a Malcom Splash screen. It check the config 
 file status and download a new splash image if the last has been changed. The class 
 should be used as any UIViewController and includes a delegate for recieving the 
 disappear event.
 @since 1.0
 */
@interface MCMConfigSplashViewController : UIViewController {

	UIImageView *imageView_;
	UILabel *statusLabel_;
	UIActivityIndicatorView *indicator_;
	id<MCMConfigSplashDelegate> delegate_;
    BOOL dataLoaded_;
	NSDate *loadDate_;
}

/**
 IBOutlet for the background image view in which should be loaded the splash image. 
 It's automatically created if no one is defined in the NIB
 @since 1.0
*/
@property(nonatomic, retain) IBOutlet UIImageView *imageView;

/**
 IBOutlet for the status label in which should be shown the status messages (updating, checkin,...). 
 It's automatically created if no one is defined in the NIB
 @since 1.0
 */
@property(nonatomic, retain) IBOutlet UILabel *statusLabel;

/**
 IBOutlet for the activity indicator for the splash screen. 
 It's automatically created if no one is defined in the NIB
 @since 1.0
 */
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;

/**
 Optional delegate to receive splash events
 @since 1.0
*/
@property(nonatomic, assign) id<MCMConfigSplashDelegate> delegate;

/**
 Boolean indicating if the splash data is already loaded or not. True when 
 the splash is ready to disappear.
 @since 1.0
 */
@property (readonly) BOOL dataLoaded;


/**
 Method that force the splash screen to be removed. It also calls to the delegate events. 
 Note that this method will be called automatically when the MCMConfigManager finish
 updating and all the conditions are completed successfully. 
 You should not call this method unless you want to alterate the normal duration 
 of the splash
 @since 1.0
 */
- (void) removeSplash;


@end
