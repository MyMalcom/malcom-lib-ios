//
//  MCMConfigManager.m
//

#import "MCMConfigManager.h"
#import "MCMConfigDefines.h"
#import "MCMCore.h"
#import "MCMCoreSingleton.h"

#import "MCMASIHTTPRequest.h"
#import "MCMASIDownloadCache.h"
#import "MCMCampaignBannerViewController.h"

@interface MCMConfigManager(private) <MCMASIHTTPRequestDelegate>

//Convert a bundle version into a integer to compare
- (NSInteger) versionStringToNumber:(NSString *)version;
//Compare Version
- (BOOL)showVersion:(NSString *)compareString version:(NSString *)configVersion with:(NSString *)versionDevice;

//Open a Webview instead of an alert
- (void) openWebViewAlert:(NSURLRequest *)request;

//Splash Manage
- (NSString *) localSplashPath;
- (NSString *) splashCode;
- (BOOL) splashHasChanged;
- (void) downloadSplash;

@end


@implementation MCMConfigManager SYNTHESIZE_SINGLETON_FOR_CLASS(MCMConfigManager)

#pragma mark ----
#pragma mark Properties
#pragma mark ----
@synthesize updating, error, lastUpdate, loaded, checkVersionOnUpdate, checkingVersion, checkSectionsOnUpdate, localFilePath, configChanged, downloadingSplash;



#pragma mark ----
#pragma mark  Life cycle methods
#pragma mark ----

- (id) init {
    
	if ((self = [super init])){
        downloadingSplash=NO;
        configChanged=NO;
        checkingVersion=NO;
		error=NO;
		updating=NO;
		loaded=NO;
		lastUpdate=nil;
		self.checkVersionOnUpdate=YES;		
		self.checkSectionsOnUpdate=YES;        
		self.localFilePath=[NSString stringWithFormat:@"%@%@%@", NSHomeDirectory(), @"/Documents/", kMalcomSettingsLocalName];
        
	}
	
	return self;
}

#pragma mark ----
#pragma mark  Public methods
#pragma mark ----


- (void)loadSettingsWithConfigUrl:(NSURL *)url{	
	//Check the file exists in bundle
	NSString *bundlePath = [[NSBundle mainBundle] pathForResource:kMalcomSettingsLocalName ofType:nil];
	if ((bundlePath==nil) && (self.loaded==NO) && (self.error==NO)){
		
        [MCMLog log:[NSString stringWithFormat:@"Malcom Config -  MCMConfigManager There is no settings file in the bundle. You should include a settings file named '%@' with the default configuration within your project", kMalcomSettingsLocalName]
             inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        
	}
	
	//Check if the settings is already in the local file or load it from bundle
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.localFilePath];
	if ((fileExists==NO) && (bundlePath!=nil)){
		[[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:self.localFilePath error:nil];
		fileExists=YES;
	}
	
	//If local file exists
	if (fileExists){
		//Load the settings from the local file
		[settings_ release];
		settings_ = [[NSDictionary alloc] initWithContentsOfFile:self.localFilePath];
        
        [self willChangeValueForKey:@"lastUpdate"];
        [lastUpdate release];
		lastUpdate=[[[[NSFileManager defaultManager] attributesOfItemAtPath:self.localFilePath error:nil] objectForKey:NSFileModificationDate] retain];
        [self didChangeValueForKey:@"lastUpdate"];
        
        [self willChangeValueForKey:@"error"];
		error=NO;
        [self didChangeValueForKey:@"error"];
        
        [self willChangeValueForKey:@"loaded"];
        loaded=YES;
        [self didChangeValueForKey:@"loaded"];

		
		//Post notification for the settings update
		[[NSNotificationCenter defaultCenter] postNotificationName:MCMConfigUpdateNotification object:nil];                
	}
	else {
        [self willChangeValueForKey:@"error"];
		error=YES;
        [self didChangeValueForKey:@"error"];
	}

	//Check if it must update the settings
	if (url){
		[self refreshSettingsForUrl:url];		
	}
}

- (void)loadSettingsWithAppId:(NSString *)appId{	
//	[MCMCoreManager sendClassesFollowingMCMToMalcom:appId];
	NSURL *url =nil;
	if (appId){
        
        NSString *path = [NSString stringWithFormat:@"v1/globalconf/%@/%@/%@.plist", [[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyMalcomAppId], [MCMCoreUtils uniqueIdentifier], kMalcomSettingsRemoteName];
        IF_IOS7_OR_GREATER(
            path = [NSString stringWithFormat:@"v1/globalconf/%@/%@/%@.plist", [[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyMalcomAppId], [MCMCoreUtils deviceIdentifier], kMalcomSettingsRemoteName];
        )
        
        url = [NSURL URLWithString:[[MCMCoreManager sharedInstance] malcomUrlForPath:path]];
        
    }
        
	[self loadSettingsWithConfigUrl:url];

}

- (void) refreshSettingsForUrl:(NSURL *)url{

	//Check there is not already updating
	if (self.updating) return;	
    [self willChangeValueForKey:@"updating"];
    updating=YES;
    [self didChangeValueForKey:@"updating"];
    
    //Create the url
	if (url==nil){
        [self requestFailed:nil];
		return;
	}	

    MCMASIHTTPRequest *request = [MCMASIHTTPRequest requestWithURL:url];
    [request setDownloadCache:[MCMASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setTimeOutSeconds:kMalcomSettingsTimeout];
    [request setDelegate:self];
    [request startAsynchronous];
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Config -  MCMConfigManager Updating settings file from %@", [url absoluteString]] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
}

- (id)settingForKey:(MCMConfigKey)key{
	
    NSString *locale = [[NSLocale preferredLanguages] objectAtIndex:0];
	
	//First, try to match the current locale
	id value = [self settingForKey:key forLocale:locale];				
	if (value) return value;
	
	//Second, try the global key without locale
	value = [self settingForCustomKey:key];
	if (value) return value;
	
	//Third, try the rest of locales
	for (int i=1; i<[[NSLocale preferredLanguages] count]; i++){
		locale = [[NSLocale preferredLanguages] objectAtIndex:i];
		value = [self settingForKey:key forLocale:locale];
		if (value) return value;
	}
	
	//Last, try the english locale
	value = [self settingForKey:key forLocale:@"en"];
	if (value) return value;
	
	//If none of the above, return nil
	return nil;
}

- (id)settingForKey:(MCMConfigKey)key forLocale:(NSString *)localeCode{
	return [self settingForCustomKey:[NSString stringWithFormat:@"%@_%@", key, localeCode]];
}

- (id)settingForCustomKey:(NSString *)key{
    
	return [settings_ objectForKey:key];
}

- (BOOL) checkVersion{
	
	//Check if the MCMConfigManager is already loaded, or load from cache if not
	if ([self loaded]==NO){
        
        [MCMLog log:@"Malcom Config - MCMConfigManager should be loaded before checking the version"
             inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
		[self loadSettingsWithConfigUrl:nil];
	}
	
	NSString *installedVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];//[[UIDevice currentDevice].systemVersion floatValue];
    
	id alert=nil;
    
    NSString *locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    if ([self settingForKey:MCMAlertType] != @"NONE") {
        
        BOOL isShowAlert = NO;
        BOOL isShowIntersitial = NO;
        
        if ([[self settingForKey:MCMVersionCondition] isEqualToString:@"NONE"]) {
            
            isShowAlert = YES;
            
        }
        else {
            
            NSString *comparateString = [self settingForKey:MCMVersionCondition];
            
            isShowAlert = [self showVersion:comparateString version:[self settingForKey:MCMConfigKeyAppStoreVersion] with:installedVersion];
            
        }
        
        if ([[self settingForKey:MCMShowInterstitial] boolValue]) {
            
            isShowIntersitial = [self showVersion:[self settingForKey:MCMIntersitialVersionCondition] version:[self settingForKey:MCMInterstitialVersion] with:installedVersion];
            
        }
        
        if (isShowIntersitial) {
            
            NSString *webIntersitial = [[NSUserDefaults standardUserDefaults] objectForKey:kWebIntersitialUserDefaults];
            NSInteger numRepetitions = [[NSUserDefaults standardUserDefaults] integerForKey:kInfoRepetitionsUserDefaults];
            NSInteger maxRepetitions = [[self settingForKey:MCMInterstitialTimesToShow] intValue];
            
            //If the message has changed, reset the repetitions counter
            
            if ([[self settingForKey:MCMInterstitialWeb] isEqualToString:webIntersitial]==NO){
            
                numRepetitions=0;
            
            }
            
            numRepetitions++;
                    
            //If should be showed...
            
            if ((numRepetitions<=maxRepetitions) || (maxRepetitions==0)){
            
                [[NSUserDefaults standardUserDefaults] setObject:[self settingForKey:MCMInterstitialWeb] forKey:kWebIntersitialUserDefaults];
                [[NSUserDefaults standardUserDefaults] setInteger:numRepetitions forKey:kInfoRepetitionsUserDefaults];
            	[[NSUserDefaults standardUserDefaults] synchronize];
            		
                NSURL *url = [NSURL URLWithString:[self settingForKey:MCMInterstitialWeb]];
                
                if (url){
                
                    alert = [[MCMCoreWebAlertView alloc] init];
                    [((MCMCoreWebAlertView *) alert) setUrl:url];
                    [alert setDelegate:self];
                
                    [alert show];
                    //[alert release];
                
                }
                
            }
            
            //			DLog(@"Malcom Config - MCMConfigManager information message");
            //		}
            
        }
        
        //isShowAlert = NO;
        if (isShowAlert) {
            
            NSString *message = [self settingForKey:[NSString stringWithFormat:@"%@_%@", @"alertMsg", locale]];
            
            if (message == nil) {
                
                message = [self settingForKey:[NSString stringWithFormat:@"%@_%@", @"alertMsg", [self settingForKey:MCMDefaultLanguage]]];
                
            }
            
            if ([[self settingForKey:MCMAlertType] isEqualToString:@"BLOCK"]) {
                
                alert = [[UIAlertView alloc] initWithTitle:[self settingForKey:MCMConfigKeyTitle]
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Close",@"") 
                                         otherButtonTitles:nil];
                
                [alert setTag:1];
                
                [MCMLog log:@"Malcom Config - MCMConfigManager app problems" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
                
            }
            else if ([[self settingForKey:MCMAlertType] isEqualToString:@"FORCE"]) {
                
                alert= [[UIAlertView alloc] initWithTitle:[self settingForKey:MCMConfigKeyTitle]
                        				 message:message
                        				 delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Close",@"") 
                                         otherButtonTitles:NSLocalizedString(@"Update",@""), nil];
                [alert setTag:2];
                
                [MCMLog log:@"Malcom Config - MCMConfigManager force update" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
                
            }
            else if ([[self settingForKey:MCMAlertType] isEqualToString:@"SUGGEST"]) {
                
                alert= [[UIAlertView alloc] initWithTitle:[self settingForKey:MCMConfigKeyTitle]
                                                  message:message
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"OK",@"") 
                                        otherButtonTitles:NSLocalizedString(@"Update",@""), nil];
                
                [alert setTag:3];
                
                [MCMLog log:@"Malcom Config - MCMConfigManager suggest update or info" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
                
            }
            else if ([[self settingForKey:MCMAlertType] isEqualToString:@"INFO"]) {
                
                alert= [[UIAlertView alloc] initWithTitle:[self settingForKey:MCMConfigKeyTitle]
                                                  message:message
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"OK",@"") 
                                        otherButtonTitles:nil];
                
                [alert setTag:0];
                
                [MCMLog log:@"Malcom Config - MCMConfigManager suggest update or info" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
                
            }
            
        }
        
    }
	
	[alert show];
	[alert release];
		 
    [self willChangeValueForKey:@"checkingVersion"];
	checkingVersion=alert!=nil;
    [self didChangeValueForKey:@"checkingVersion"];
	return checkingVersion;
}



- (UIImage *) splashImage{
	return [self splashImageForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (UIImage *) splashImageForOrientation:(UIInterfaceOrientation)orientation{
	NSString *localSplashPath = [self localSplashPath];
	UIImage *splashImage = nil;
	
	//If there is already a previous splash image, we use it
	if ([[NSFileManager defaultManager] fileExistsAtPath:localSplashPath]){
		splashImage=[UIImage imageWithContentsOfFile:localSplashPath];					
	}
	//Else, we use the Default included in the bundle
	else {
        //Look for the orientation
        if (UIDeviceOrientationIsLandscape(orientation)){
            splashImage=[UIImage imageNamed:@"Default-Landscape"];
            
            //If no valid image loaded, try to load with extension (before iOS4)
            if (splashImage==nil)
                splashImage=[UIImage imageNamed:@"Default-Landscape.png"];		
        }
        else {
            splashImage=[UIImage imageNamed:@"Default-Portrait"];		        
            
            //If no valid image loaded, try to load with extension (before iOS4)
            if (splashImage==nil)
                splashImage=[UIImage imageNamed:@"Default-Portrait.png"];		
        }
        //If no valid image loaded, try to load the default
        if (splashImage==nil)
            splashImage=[UIImage imageNamed:@"Default"];		
        
        //If no valid image loaded, try to load with extension (before iOS4)
        if (splashImage==nil)
            splashImage=[UIImage imageNamed:@"Default.png"];		
        
	}
	
	return splashImage;
}

#pragma mark ----
#pragma mark  Private methods
#pragma mark ----

- (NSInteger) versionStringToNumber:(NSString *)version{	
	if ((version==nil)||([version length]<=0)) return NSIntegerMax;
	return [[version stringByReplacingOccurrencesOfString:@"." withString:@"000"] intValue];
}

//Compare Version
- (BOOL)showVersion:(NSString *)compareString version:(NSString *)configVersion with:(NSString *)versionDevice {
    
    BOOL isShowAlert = NO;
    
    NSInteger comparator = [versionDevice compare:configVersion options:NSNumericSearch];
    
    if ([compareString isEqualToString:@"NONE"]) {
        
        isShowAlert = YES;
        
    }
    else {
        
        if ([compareString isEqualToString:@"GREATER_EQUAL"]) {
            
            if (comparator >= 0) {
                
                isShowAlert = YES;
                
            }
            
        }
        else if ([compareString isEqualToString:@"GREATER"]) {
            
            if (comparator > 0) {
                
                isShowAlert = YES;
                
            }
            
        }
        else if ([compareString isEqualToString:@"LESS"]) {
            
            if (comparator < 0) {
                
                isShowAlert = YES;
                
            }
            
        }
        else if ([compareString isEqualToString:@"LESS_EQUAL"]) {
            
            if (comparator <= 0) {
                
                isShowAlert = YES;
                
            }
            
        }
        else if ([compareString isEqualToString:@"EQUAL"]) {
            
            if (comparator == 0) {
                
                isShowAlert = YES;
                
            }
            
        }
        
    }
    
    return isShowAlert;
    
}

- (NSString *) localSplashPath{
	return [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/splash"]; 
}


- (NSString *) splashCode {
	NSString *splashUrl = [self settingForKey:MCMConfigKeySplashImageUrl];
	NSString *splashName = [self settingForKey:MCMConfigKeySplashImageName];
	return [NSString stringWithFormat:@"%@/%@", splashName, splashUrl];
}


- (BOOL) splashHasChanged {
	NSString *lastCode = [[NSUserDefaults standardUserDefaults] valueForKey:kSplashCodeUserDefaults];
	if (lastCode==nil) return YES;
	return (![[self splashCode] isEqualToString:lastCode]);
}

- (void) downloadSplash {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self retain];
	
	[self willChangeValueForKey:@"downloadingSplash"];
	downloadingSplash=YES;
	[self didChangeValueForKey:@"downloadingSplash"];
	
	NSString *splashUrl = [self settingForKey:MCMConfigKeySplashImageUrl];
	
	//If splashUrl defined
	if (splashUrl){
		NSURL *url = [NSURL URLWithString:splashUrl];
		if (url){
			
			//Download the new splash
			NSURLRequest *request = [NSURLRequest requestWithURL:url];
			NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
			
			//If returned data is OK, save it on local splash path
			if (data){				
				UIImage *image = [UIImage imageWithData:data];
				if (image){
					[data writeToFile:[self localSplashPath] atomically:YES];
					[[NSUserDefaults standardUserDefaults] setValue:[self splashCode] forKey:kSplashCodeUserDefaults];
					[[NSUserDefaults standardUserDefaults] synchronize];
				}
			}
		}
	}
	else {
		if ([[NSFileManager defaultManager] fileExistsAtPath:[self localSplashPath]]){
			[[NSFileManager defaultManager] removeItemAtPath:[self localSplashPath] error:nil];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:kSplashCodeUserDefaults];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}		
	}
    
    
	[self willChangeValueForKey:@"downloadingSplash"];
	downloadingSplash=NO;
	[self didChangeValueForKey:@"downloadingSplash"];
	
	[self release];
	[pool release];
}


#pragma mark ----
#pragma mark ASIHTTPRequest delegate methods
#pragma mark ----


- (void)requestFinished:(MCMASIHTTPRequest *)request {
    
    //if ([request didUseCachedResponse]==NO){
        // Use when fetching binary data
        NSData *data = [request responseData];
        
        //Check there is data
        if ([data length]<=0){
            [self requestFailed:request];
            return;
        }
        
        //Check if the data is equal to the last loaded
        NSData *oldData = [NSData dataWithContentsOfFile:[self localFilePath]];
                
        if (([oldData length]<=0) || ([data isEqualToData:oldData]==NO)){
            
            //Try to read the received data by storing in temp directory
            NSString *tempPath = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), kMalcomSettingsLocalName];
            [data writeToFile:tempPath atomically:NO];
            NSDictionary *tempDict = [NSDictionary dictionaryWithContentsOfFile:tempPath];
                        
            if ([tempDict count]<=0){
                [self requestFailed:request];
                return;
            }
            
            //Write the data into settings file
            [data writeToFile:[self localFilePath] atomically:NO];
            
            //Set the change
            [self willChangeValueForKey:@"configChanged"];
            configChanged=YES;
            [self didChangeValueForKey:@"configChanged"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MCMConfigChanged" object:nil];
            
            //Reload settings from cached file
            [self loadSettingsWithConfigUrl:nil];		
        }
    //}
    
	//Check the version
	if (self.checkVersionOnUpdate)
		[self checkVersion];	
	
	//Check the sections
	if ((self.checkSectionsOnUpdate) && ([self settingForKey:MCMConfigKeyUrlOPMLSections])){
		[[MCMConfigSectionManager sharedInstance] loadSectionsWithOPMLUrl:[NSURL URLWithString:[self settingForKey:MCMConfigKeyUrlOPMLSections]]];	
    }
	
	//Refresh the properties
    [self willChangeValueForKey:@"error"];
    error=NO;
    [self didChangeValueForKey:@"error"];
    
    [self willChangeValueForKey:@"updating"];
    updating=NO;
    [self didChangeValueForKey:@"updating"];
    
    //If the splash has changed since last upload, download in background
    if (([self splashHasChanged]) && (!downloadingSplash)){
        [self performSelectorInBackground:@selector(downloadSplash) withObject:nil];
    }

}

- (void)requestFailed:(MCMASIHTTPRequest *)request
{
    NSError *err = [request error];
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Config - MCMConfigManager  Error receiving the configuration file: %@", [err description]] 
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        
	//Check the version
	if (self.checkVersionOnUpdate)
		[self checkVersion];	
	
    //Check the sections
	if (self.checkSectionsOnUpdate)
		[[MCMConfigSectionManager sharedInstance] loadSectionsWithOPMLUrl:[NSURL URLWithString:[self settingForKey:MCMConfigKeyUrlOPMLSections]]];	
    
    [self willChangeValueForKey:@"error"];
    error=YES;
    [self didChangeValueForKey:@"error"];
    
    [self willChangeValueForKey:@"updating"];
    updating=NO;
    [self didChangeValueForKey:@"updating"];
}


#pragma mark ----
#pragma mark UIAlertViewDelegate methods
#pragma mark ----

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	switch ([alertView tag]) {
		//App problems
		case 1:
			exit(0);
			break;
			
		//Force update
		case 2:
			//Close button
			if (buttonIndex==0){
				exit(0);
			}
			//Open AppStore
			else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self settingForKey:MCMConfigKeyUrlAppStore]]];
			}
			break;			
			
		//Suggest update
		case 3:
			//Open AppStore
			if (buttonIndex>0){
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self settingForKey:MCMConfigKeyUrlAppStore]]];
			}
			break;
	}
	
    [self willChangeValueForKey:@"checkingVersion"];
	checkingVersion=NO;
	[self didChangeValueForKey:@"checkingVersion"];
    
}


#pragma mark ----
#pragma mark MCMConfigWebAlertDelegate methods
#pragma mark ----

- (void) webAlertClose:(MCMCoreWebAlertView *)alert{
    [self willChangeValueForKey:@"checkingVersion"];
	checkingVersion=NO;
    [self didChangeValueForKey:@"checkingVersion"];
}

@end
