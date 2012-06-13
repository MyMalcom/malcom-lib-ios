//
//  UITabBarController+MCMConfig.m
//

#import "UITabBarController+MCMConfig.h"
#import "MCMConfigSectionManager.h"
#import "MCMCoreDefines.h"
#import "MCMLog.h"

@implementation UITabBarController(MCMConfig)



- (void) loadViewControllersFromMCMConfig{
    if ([[MCMConfigSectionManager sharedInstance] loaded]==NO){
		
        [MCMLog log:[NSString stringWithFormat:@"Malcom Config - MCMConfigSectionManager should be loaded before loading the sections"] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
	}
	
    //Get the UIViewControllers to create in the tab bar
    NSArray *viewControllers = [[MCMConfigSectionManager sharedInstance] sectionViewControllers];
    
    //Add a Navigation controller in each
    NSMutableArray *navViewControllers = [[NSMutableArray alloc] init];
    for (UIViewController *vc in viewControllers){        
        UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:vc];
		[navViewControllers addObject:navVc];
		[navVc release];		
    }
        
	//Set the viewControllers for the tabbar
	if ([navViewControllers count]>0){
		[self setViewControllers:navViewControllers];
	}
	else {
		
        [MCMLog log:[NSString stringWithFormat:@"Malcom Config - MCMConfigSectionManager does not have any valid section configured"] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
	}
    
	[navViewControllers release];	
}

@end
