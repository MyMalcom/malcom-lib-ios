
#import <Foundation/Foundation.h>


@protocol MCMAdViewControllerDelegate <NSObject>

@optional
/**
 Implement this method if you want to avoid autoloading of advertising
 in your viewcontroller
 @returns BOOL NO if it shouldn't load advertising on this controller. Default behaviour YES
 @since 1.1.0
 */
- (BOOL) shouldLoadAd;


@end
