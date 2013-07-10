
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


/**
 Class that manages the MCMStats module. It's responsable of registering beacons (user sessions)
 and subbeacons (events or minisessions), as well as active the locator service if the user
 should be located automatically. It exposes a set of properties to use just in case the developer
 need to change something at runtime
 @since 1.0
 */
@interface MCMStatsManager : NSObject <CLLocationManagerDelegate> {

@private 
    NSString *applicationCode_;
    NSDate *startedOn_;	
    NSDate *stoppedOn_;	
    CLLocation *location_;
    BOOL coreLocation_;
    BOOL useOnlyWifi_;	
    NSString *city_;
    
    NSMutableDictionary *subbeaconsDictionary_;
    NSMutableArray * subbeaconsArray_;
	
}

/**
 Indicate the Malcom App Id. You dont need to set this if you call the init method
 @since 1.0
 */
@property (nonatomic, retain) NSString *applicationCode;

/**
 Date when the beacons started to be registered. Set when beacons start
 @since 1.0
 */
@property (nonatomic, retain) NSDate *startedOn;	

/**
 Date when the beacons stoped to be registered. Set when beacons stop if you haven't set
 any otherone previously
 @since 1.0
 */
@property (nonatomic, retain) NSDate *stoppedOn;	

/**
 Location of the user. Should be set be the developer if the coreLocation property has been set
 to NO and you still want the user location
 @since 1.0
 */
@property (nonatomic, retain) CLLocation *location;

/**
 Indicates if the data should be sent only under a Wifi connection
 @since 1.0
 */
@property (nonatomic) BOOL useOnlyWifi;

/**
 Indicates if the manager should try to geolocate the user. Note that when geolocating the user
 will be prompted
 @since 1.0
 */
@property (nonatomic) BOOL coreLocation;

/**
 City of the user. Should be set be the developer if the coreLocation property has been set
 to NO and you still want the user location
 @since 2.0
 */
@property (nonatomic, retain) NSString *city;

/**
 Gets the singleton instance for this class
 @returns Singleton object for the class
 @since 1.0
 */
+ (MCMStatsManager *) sharedInstance;

/**
 Initializes the application manager with the main parameters and start the beacons
 @param theApplicationCode MalcomAppId for the app
 @param useCoreLocation Boolean indicationg if it should use CoreLocation to locate the users position. You
 can pass NO if you already have the user location (and set it with the property location) or if you
 dont want the user to be located. Note that when using location, the user will be prompted
 @param useOnlyWifi Boolean indicationg whether the manager should only send the statistics to the Malcom 
 server with Wifi only or with any kind of Internet connection
 @returns Singleton object for the class
 @since 1.0
 */
+ (id)initAndStartBeaconWithApplicationCode:(NSString *)theApplicationCode 
                            useCoreLocation:(BOOL)coreLocation 
                                useOnlyWiFi:(BOOL)wifiState;

/**
 Delete any previous beacons or subbeacons stored in the cache
 @since 1.0
 */
+ (void) clearCache;

/**
 Starts registering statistics about time and subbeacons
 @since 1.0
 */
- (void)startBeacon;

/**
 Ends registering statistics and sends the information to the server if the Internet 
 connection is enough. If not, it caches the current information for sending the next time
 @since 1.0
 */
- (void)endBeacon;

/**
 Creates a new Subbeacon with a name and time. Subbeacons are like events inside a user
 session
 @param beaconName The subbeacon name
 @param init paramsDictionary for event
 @param type indicates if it is a subbeacon custom, special or error (and so on)
 @param timeSession Boolean indicating if it must track the time that the subbeacon lasted
 @since 1.0
 */
- (void)startSubBeaconWithName:(NSString *) beaconName forType:(NSString*) type andParams: (NSDictionary *) paramsDictionary timeSession:(BOOL)trackSession;

/**
 Ends a new Subbeacon with a name previously created with the startSubbeaconXXX method.
 @param beaconName The subbeacon name to finish
 @param final paramsDictionary for event
 @since 1.0
 */
- (void)endSubBeaconWithName:(NSString *) beaconName andParams: (NSDictionary *) paramsDictionary;

/**
 Get tags
 return tags
 @since 2.0.0
 */
+ (NSArray *)getTags;

/**
 Add tags to beacon
 @param tags
 @since 2.0.0
 */
+ (void)setTags:(NSArray *)tags;

/**
 Adds single tag to tags array
 @param tagName
 @since 2.0.3
 */
+ (void)addTag:(NSString *)tagName;

/**
 Removes single tag from tags array
 @param tagName
 @since 2.0.3
 */
+ (void)removeTag:(NSString *)tagName;


@end
