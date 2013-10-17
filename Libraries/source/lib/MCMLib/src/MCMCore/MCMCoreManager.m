
#import "MCMCoreManager.h"
#import "MCMCore.h"
#import "MCMCoreDefines.h"
#import "MCMCoreSingleton.h"
#import <objc/runtime.h>
#import "MCMConfigAdapter.h"

@interface MCMCoreManager(private)


@end


@implementation MCMCoreManager SYNTHESIZE_SINGLETON_FOR_CLASS(MCMCoreManager)


#pragma mark ----
#pragma mark  LifeCycle methods
#pragma mark ----

- (id) init {    
	if ((self = [super init])){
        
        //Create existing modules
        modules_=[[NSMutableArray alloc] init];
		NSArray *modules = [MCMCoreManager classesSubclassingClass:@"MCMModuleAdapter"];
        
        for (Class cls in modules){
            //Check if the module should be loaded automatically
            if ([cls moduleShouldAutoload]){
                id module = [[cls alloc] init];
                [modules_ addObject:module];
                [module release];
            }
        }
	}	
	return self;
}


- (void) dealloc{
    [modules_ release]; modules_=nil;
    [settings_ release]; settings_=nil;
    [super dealloc];
}

#pragma mark ----
#pragma mark  Public class methods
#pragma mark ----


- (NSString *)malcomAppId{
    return [self valueForKey:kMCMCoreKeyMalcomAppId];
}

- (NSString *)valueForKey:(NSString *)key{        
    if (settings_==nil){
        NSString *bundlePath = nil;    
        
        //If development mode, try to load the development file first
        if ([self developmentMode]){
            bundlePath = [[NSBundle mainBundle] pathForResource:kMCMCoreInfoPlistNameDevelopment ofType:nil];        
            if (bundlePath==nil){
                
                [MCMLog log:[NSString stringWithFormat:@"Malcom Core - MCMCoreManager There is no configuration file for development in the bundle. You should include a configuration file named '%@' with the required constants for development within your project to have a sandbox environment. Taking the production environment in the meanwhile", kMCMCoreInfoPlistNameDevelopment]
                     inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
                
            } else {
                
                [MCMLog log:@"Malcom Core - MCMCoreManager  Development Configuration file used" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
                
            }
        }
        
        //Try to read the settings from userDefaults
        settings_ = [[[NSUserDefaults standardUserDefaults] objectForKey:kMCMCoreInfoPlistName] retain];
        
        if (settings_ == nil) {
            
            //Try to read the bundle distribution file if no one previously assigned
            if (bundlePath==nil){
                bundlePath = [[NSBundle mainBundle] pathForResource:kMCMCoreInfoPlistName ofType:nil];
            }
            
            //If no configuration file included, raise an exception
            if (bundlePath==nil){
                
                [[NSException exceptionWithName:[NSString stringWithFormat:@"%@ not found", kMCMCoreInfoPlistName] reason:[NSString stringWithFormat:@"There is no configuration file in the bundle. You should include a configuration file named '%@' with the required constants of your project", kMCMCoreInfoPlistName] userInfo:nil] raise];
                
            } else {
                
                //Read the configuration and close
                settings_ = [[NSDictionary alloc] initWithContentsOfFile:bundlePath];
                
            }
        }
    }
    
    return [settings_ valueForKey:key];
}

- (NSString *)malcomUrlForPath:(NSString *)path{
    return [[self valueForKey:kMCMCoreKeyMalcomBaseUrl] stringByAppendingString:path];
}

- (NSString *)assetsUrlForPath:(NSString *)path{
    return [[self valueForKey:kMCMCoreKeyAssetsBaseUrl] stringByAppendingString:path];
}

- (BOOL)developmentMode{
//#ifndef DISTRIBUTION
//#error Debe definir la variable 'DISTRIBUTION' en 'Other C Flags' del compilador!
//#else
    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"developmentMode"] boolValue];
    
//#if DISTRIBUTION
//    NSLog(@"__________________DISTRIBUTION");
//    return NO;
//#else
//    NSLog(@"__________________DEBUG");
//    return YES;
//#endif
//#endif
}

- (void) sendClassesFollowingMCMToMalcom:(NSString *)appId{
#if (TARGET_IPHONE_SIMULATOR)
	//TODO: Get classes and send to Malcom
    [[NSException exceptionWithName:@"Not implemented" reason:@"sendClassesFollowingMCMToMalcom not implemented in this version of MCMLib. Please update to the last" userInfo:nil] raise];
#else
	[MCMLog log:[NSString stringWithFormat:@"Malcom Core - MCMCoreManager::classesFollowingMCMSectionProtocol not available for device binaries"] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
#endif
}


+ (NSArray *) classesImplementingProtocol:(NSString *)protocolName{
    
    NSMutableArray *classesArray = [[NSMutableArray alloc] init];
	
	//Count the total number of classes and extract the protocol
	Protocol *protocol = objc_getProtocol([protocolName UTF8String]);	
	int numClasses = objc_getClassList(NULL, 0);
	
	if (numClasses > 0 ){
		
		//Get the classes
		Class * classes = malloc(sizeof(Class) * numClasses);		
		numClasses = objc_getClassList(classes, numClasses);
		
		//For each class
		for (int i=0; i<numClasses; i++){
			
			//Check if conforms the protocol
			Class cls = classes[i];
			if (class_conformsToProtocol(cls, protocol)){
				
				//Add the class to the array of found classes
				[classesArray addObject:cls];
			}
		}
		free(classes);
		
	}
	
	return [classesArray autorelease];    
}


+ (NSArray *) classesSubclassingClass:(NSString *)className{
	//Count the total number of classes and extract the protocol
	Class parentCls = NSClassFromString(className);
    if (parentCls == nil) return nil;
    
    NSMutableArray *classesArray = [[NSMutableArray alloc] init];
	int numClasses = objc_getClassList(NULL, 0);
	
	if (numClasses > 0 ){
		
		//Get the classes
		Class * classes = malloc(sizeof(Class) * numClasses);		
		numClasses = objc_getClassList(classes, numClasses);
		
		//For each class
		for (int i=0; i<numClasses; i++){
			
			//Check if its parent or granparent is the class
			Class cls = classes[i];
            
            
            
			if (class_getSuperclass(cls)==parentCls){
				//Add the class to the array of found classes
				[classesArray addObject:cls];            
			}else if (class_getSuperclass(class_getSuperclass(cls))==parentCls){
				[classesArray addObject:cls];                            
            }
		}
		free(classes);		
	}
	
	return [classesArray autorelease];    
}

#pragma mark ----
#pragma mark  Private methods
#pragma mark ----


//Backward compatibility
- (void)applicationDidFinishLaunching:(UIApplication *)application{
    [self application:application didFinishLaunchingWithOptions:nil];
}

#pragma mark ----
#pragma mark  MCMCoreModuleAdapter overriden methods
#pragma mark ----

+ (BOOL) moduleShouldAutoload {
    //No autoload because Core is loaded manually with a singleton patern
    return NO;
}

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{ 
        
    for (MCMModuleAdapter *module in modules_){
        [module application:application didFinishLaunchingWithOptions:launchOptions];
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application{ 
    for (MCMModuleAdapter *module in modules_){
        [module applicationWillResignActive:application];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    for (MCMModuleAdapter *module in modules_){
        [module applicationDidEnterBackground:application];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application{ 
    for (MCMModuleAdapter *module in modules_){
        [module applicationWillEnterForeground:application];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application{ 
    for (MCMModuleAdapter *module in modules_){
        [module applicationDidBecomeActive:application];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application{ 
    for (MCMModuleAdapter *module in modules_){
        [module applicationWillTerminate:application];
    }
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken{ 
    for (MCMModuleAdapter *module in modules_){
        [module application:app didRegisterForRemoteNotificationsWithDeviceToken:devToken];
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err{ 
    for (MCMModuleAdapter *module in modules_){
        [module application:app didFailToRegisterForRemoteNotificationsWithError:err];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{ 
    for (MCMModuleAdapter *module in modules_){
        [module application:application didReceiveRemoteNotification:userInfo];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    for (MCMModuleAdapter *module in modules_){
        [module applicationDidReceiveMemoryWarning:application];
    }
}

//UIViewController messages

- (void)viewDidLoad:(UIViewController*)vc{ 
    for (MCMModuleAdapter *module in modules_){
        [module viewDidLoad:vc];
    }
}

- (void)viewDidUnload:(UIViewController *)vc{ 
    for (MCMModuleAdapter *module in modules_){
        [module viewDidUnload:vc];
    }
}

- (void)viewAppear:(UIViewController *)vc{ 
    for (MCMModuleAdapter *module in modules_){
        [module viewAppear:vc];
    }
}

-(void) viewDisappear:(UIViewController *)vc{ 
    for (MCMModuleAdapter *module in modules_){
        [module viewDisappear:vc];
    }
}

- (void)viewRotate:(UIViewController *)vc toOrientation:(UIInterfaceOrientation)orientation{
    for (MCMModuleAdapter *module in modules_){
        [module viewRotate:vc toOrientation:orientation];
    }
}


//DEPRECATED. Included for compatibility with integrations previous to 1.0.4
- (void)viewWillAppear:(BOOL)animated vc:(UIViewController *)vc{ 
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Core - MCMCoreManager Use of [MCMCoreManager viewDidAppear] event deprecated. Using viewAppear instead"] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    [self viewAppear:vc];
}
- (void)viewDidAppear:(BOOL)animated vc:(UIViewController *)vc{ 
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Core - MCMCoreManager Use of [MCMCoreManager viewWillAppear] event deprecated."] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
}
-(void) viewWillDisappear:(BOOL)animated vc:(UIViewController *)vc{ 
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Core - MCMCoreManager Use of [MCMCoreManager viewWillDisappear] event deprecated. Using viewDisappear instead"] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    [self viewDisappear:vc];
}
-(void) viewDidDisappear:(BOOL)animated vc:(UIViewController *)vc{ 
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Core - MCMCoreManager Use of [MCMCoreManager viewDidDisappear] event deprecated."] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
}

@end
