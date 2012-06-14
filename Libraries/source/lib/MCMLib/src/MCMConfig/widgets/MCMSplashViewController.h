//
//  MCMSplashViewController.h
//  malcommodule
//
//  Created by Alfonso Miranda Castro on 05/03/12.
//  Copyright (c) 2012 Mobivery. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCMSplashViewController : UIViewController {
    
    UIActivityIndicatorView *indicator_;
	BOOL showed_;
    NSDate *loadDate_;
    UILabel *statusLabel_;
    UIImageView *imageView_;
    
}

/**
 IBOutlet for the status label in which should be shown the status messages (updating, checkin,...). 
 It's automatically created if no one is defined in the NIB
 @since 1.0
 */
@property(nonatomic, retain) IBOutlet UILabel *statusLabel;
@property(nonatomic, retain) UIImageView *imageView;

- (void) show;

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
