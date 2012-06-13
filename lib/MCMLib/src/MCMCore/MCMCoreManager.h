
#import <Foundation/Foundation.h>
#import "MCMModuleAdapter.h"

/**
 Singleton class that manages the foundations of Malcom Library. It's responsable of loading all the 
 existing module adapters and bypassing UIApplicationDelegate and UIViewController principal events to
 each loaded module.
 @since 1.0
 */
@interface MCMCoreManager : MCMModuleAdapter {
 
    NSMutableArray *modules_;
    NSDictionary *settings_;
}

/**
 Return the MalcomAppId for this application
 @return MalcomAppId
 @since 1.0
 */
- (NSString *)malcomAppId;

/**
 Return a value stored in the Core settings file. Note that this file is not uploaded remotely
 @param key Key to look
 @return value for looked key
 @since 1.0
 */
- (NSString *)valueForKey:(NSString *)key;

/**
 Return a full url associated to a path in Malcom. It uses the MCMCore-Info base url
 @param path Path of the resource in Malcom
 @return Full url for malcom path
 @since 1.0
 */
- (NSString *)malcomUrlForPath:(NSString *)path;

/**
 Return a full url associated to a path in Assets. It uses the MCMCore-Info base url
 @param path Path of the asset in Malcom
 @return Full url for asset path
 @since 1.0
 @deprecated
 */
- (NSString *)assetsUrlForPath:(NSString *)path;


/**
 Return a bool indicating if the development mode is active or we are running in production
 @return TRUE if the app is in development mode or FALSE if in production
 @since 1.0.3
 */
- (BOOL)developmentMode;

/**
 Return an array of classes implementing the current protocol
 @param protocolName Name of the protocol
 @return array of classes (instances of Class) implementing protocol
 @since 1.0
 */
+ (NSArray *) classesImplementingProtocol:(NSString *)protocolName;


/**
 Return an array of classes extending the current class name
 @param className Name of the protocol
 @return array of classes (instances of Class) which extends className (but not className itself)
 @since 1.0
 */
+ (NSArray *) classesSubclassingClass:(NSString *)className;

/**
 Gets the singleton instance for this class
 @returns Singleton object for the class
 @since 1.0
 */
+ (MCMCoreManager *)sharedInstance;

@end
