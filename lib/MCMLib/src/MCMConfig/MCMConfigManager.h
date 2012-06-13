#import <Foundation/Foundation.h>
#import "MCMConfig.h"

/**
 Singleton class that manages all the communication with the Malcom Server. This class should be instantiated
 before any other class or widget from the library
 @since 1.0
 */
@interface MCMConfigManager : NSObject {
	NSDictionary *settings_;
}

#pragma mark ----
#pragma mark  Property declaration
#pragma mark ----

/**
 Shows if the manager is already loaded with any configuration file
 @since 1.0
 */
@property(readonly) BOOL loaded;

/**
 Shows if the manager is updating the file from server
 @since 1.0
 */
@property(readonly) BOOL updating;

/**
 Shows if the manager encountered errors while updating
 @since 1.0
 */
@property(readonly) BOOL error;

/**
 Shows the date of the last succesfully updated file
 @since 1.0
 */
@property(readonly) NSDate *lastUpdate;

/**
 Indicate if the version should be automatically checked when finish updating the config file. Defaults YES
 @since 1.0
 */
@property BOOL checkVersionOnUpdate;

/**
 Shows if the version is being checked or the user is prompt with an alert
 @since 1.0
 */
@property(readonly) BOOL checkingVersion;

/**
 Indicate if the manager should check if some new changes on the sections have been done and 
 calls the MCMConfigSectionManager when finish updating the config file. Defaults YES
 @since 1.0
 */
@property BOOL checkSectionsOnUpdate;

/**
 Indicate local file path of the downloaded file. By default in Documents/MCMConfig-Info.plist
 @since 1.0
 */
@property(retain) NSString *localFilePath;


/**
 Indicate if there is any change since the last update of the file
 @since 1.0
 */
@property(readonly) BOOL configChanged;


/**
 Boolean indicating if the manager is downloading a new splash
 image or not. Splash image downloads run in background.
 @since 1.0
 */
@property(readonly) BOOL downloadingSplash;



#pragma mark ----
#pragma mark  Public methods declaration
#pragma mark ----

/**
 Gets the singleton instance for this class
 @returns Singleton object for the class
 @since 1.0
 */
+ (MCMConfigManager *)sharedInstance;

/**
 Loads the last cached configuration file and try to update it from the server if desired
 @param url URL for the remote configuration file in Malcom. Could be nil if no update needed
 @since 1.0
 */
- (void)loadSettingsWithConfigUrl:(NSURL *)url;

/**
 Loads the last cached configuration file and try to update it from the server if desired
 @param appId Malcom Application Id used to load the configuration file. Could be nil if no update needed
 @since 1.0
 */
- (void)loadSettingsWithAppId:(NSString *)appId;

/**
 Forces the settings to be updated from the server with the given url. It does anything if it's already updating.
 Note this method is called automatically when "loadSettingsXXX" is called with a proper parameter. 
 @param url Remote url used for updating
 @since 1.0
 */
- (void) refreshSettingsForUrl:(NSURL *)url;

/**
 Get the settings for a predefined Malcom's key. It tries to find the key with the user's
 default locale before looking for the global one
 @param key Malcom key
 @returns object associated to the key or nil if none 
 @since 1.0
 */
- (id)settingForKey:(MCMConfigKey)key;

/**
 Get the settings for a predefined Malcom's key with a custom locale
 @param key Malcom key
 @param locale Language code of the locale
 @returns object associated to the key or nil if none
 @since 1.0
 */
- (id)settingForKey:(MCMConfigKey)key forLocale:(NSString *)localeCode;

/**
 Get the settings for a custom key
 @param key Custom key name
 @returns object associated to the key or nil if none
 @since 1.0
 */
- (id)settingForCustomKey:(NSString *)key;


/**
 Checks the appVersion with the one within the configuration file and shows an alert or webview if needed
 @return Bool indicating if an alert or webview has been shown
 @since 1.0
 */
- (BOOL) checkVersion;

/**
 Return the last splash image downloaded (or Default if none)
 @return UIImage Last splash downloaded
 @since 1.0
 */
- (UIImage *) splashImage;

/**
 Return the last splash image downloaded (or Default if none) based on the orientation asked
 @param orientation Orientation for the new splash image
 @return UIImage Last splash downloaded
 @since 1.0.1
 */
- (UIImage *) splashImageForOrientation:(UIInterfaceOrientation)orientation;

@end
