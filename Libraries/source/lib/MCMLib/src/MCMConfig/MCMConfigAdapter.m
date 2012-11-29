
#import "MCMConfigAdapter.h"
#import "MCMConfig.h"
#import "MCMCore.h"


@implementation MCMConfigAdapter


- (void) dealloc {
    [splashController_ release]; splashController_=nil;
    [tabBarController_ release]; tabBarController_=nil;
    [super dealloc];
}

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{ 
    //MCMConfig init
    
    [self copyIfNeededFile:@"MCMConfig-Info.plist" ofType:nil];
    
	[[MCMConfigManager sharedInstance] loadSettingsWithAppId:[[MCMCoreManager sharedInstance] malcomAppId]];
 
    //Create a splashController
	splashController_ = [[MCMConfigSplashViewController alloc] initWithNibName:nil bundle:nil];	
	[((MCMConfigSplashViewController *) splashController_) setDelegate:((id<MCMConfigSplashDelegate>)self)];
    
    splashLoaded_=YES;
 
    //Add Splash to main window
    [[[application windows] objectAtIndex:0] addSubview:splashController_.view];    
    [splashController_.view.superview performSelector:@selector(bringSubviewToFront:) withObject:splashController_.view afterDelay:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IntersitialBringToFront" object:nil];
  
    //Notify the AppDelegate
    if ([[application delegate] respondsToSelector:@selector(splashLoaded:)]){
        [((id<MCMConfigApplicationDelegate>) [application delegate]) splashLoaded:splashController_];
    }    
}


- (void)applicationWillEnterForeground:(UIApplication *)application{

    splashLoaded_=NO;
    
    //MCMConfig init
	[[MCMConfigManager sharedInstance] loadSettingsWithAppId:[[MCMCoreManager sharedInstance] malcomAppId]];    
}


- (void) applicationDidEnterBackground:(UIApplication *)application {
    
    //Close Intersitial if exist
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MCMCloseIntersitialNotification object:nil];
    //Check if there is any change since last refresh
    if (([[MCMConfigManager sharedInstance] configChanged]) || ([[MCMConfigSectionManager sharedInstance] sectionsChanged])){
        //if the splash was not load, we need to terminate the app to refresh from the start on the next execution
        if (splashLoaded_==NO){
            exit(0);
        }
    }
}

#pragma mark MCMConfigSplashDelegate methods


- (BOOL) splashShouldDisappear:(MCMConfigSplashViewController *)splashViewController{   

    //Try to get the tabbar from the UIApplicationDelegate
	tabBarController_ = nil;
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(tabBarController)]){
        tabBarController_ = [[((id) [[UIApplication sharedApplication] delegate]) tabBarController] retain];
    }    
    
    //If no existing tabbar, create one
    if (tabBarController_==nil){
        tabBarController_ = [[UITabBarController alloc] init];
    }	
    
    //Load configured sections
	[tabBarController_ loadViewControllersFromMCMConfig];
    
    //Check at least one section loaded to add to the window
    if ([tabBarController_.viewControllers count]>0){
        
        //Check if the app delegate has a tabbar property to be set
        if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(setTabBarController:)]){
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(setTabBarController:) withObject:tabBarController_];
        }
        
        //Add the tabbar in the main window
        if (tabBarController_.view.superview==nil){
            
//            [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:tabBarController_.view];
            
            [tabBarController_.view.superview sendSubviewToBack:tabBarController_.view];  
            
        }
//        
//        //If root viewController available, set the new tabbar
//        if ([[[[UIApplication sharedApplication] windows] objectAtIndex:0] respondsToSelector:@selector(setRootViewController:)]){
//            [[[[UIApplication sharedApplication] windows] objectAtIndex:0] performSelector:@selector(setRootViewController:) withObject:tabBarController_];
//        }
//    }
//    
//    //Notify the AppDelegate
//    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(splashUnloaded:)]){
//        [[[UIApplication sharedApplication] delegate] performSelector:@selector(splashUnloaded:) withObject:splashViewController];
    }    
    
    return YES;
}

#pragma -
#pragma Private Methods


- (BOOL)copyIfNeededFile:(NSString *)fileName ofType:(NSString *)type {
	BOOL copiado = NO;
	
	// Comprobamos si ya existe el fichero en la carpeta Documents.
	BOOL existe;
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
	existe = [[NSFileManager defaultManager] fileExistsAtPath:writableFilePath];
	if (!existe) {
		NSString *defaultFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
		existe = [[NSFileManager defaultManager] copyItemAtPath:defaultFilePath toPath:writableFilePath error:&error];
		
		if (!existe) {
			NSAssert1(0, @"Error al crear la copia editable de un fichero con el mensaje '%@'.", [error localizedDescription]);
		} else {
			copiado = YES;
		}
	}
	
	return copiado;
}


@end
