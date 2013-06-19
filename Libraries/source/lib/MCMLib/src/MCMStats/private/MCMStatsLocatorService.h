//
// $Id: MCMStatsLocatorService.h 10377 2009-09-28 15:41:28Z ascandroli $
//
// Abstract: Singleton class used to talk to CoreLocation and send results back to
// the app's view controllers.
//

#import <CoreLocation/CoreLocation.h>

// Class definition
@interface MCMStatsLocatorService : NSObject <CLLocationManagerDelegate> {
	
@private CLLocationManager *locationManager;
@private CLLocation *currentLocation;
@private BOOL locating;
@private NSArray *desiredPrecisions;
@private NSArray *desiredAccuracies;
@private int desiredIndex;
@private BOOL locationSuccessful;
@private BOOL locationAllowed;

}

@property (nonatomic, retain) CLLocation *currentLocation;
@property (assign, nonatomic) BOOL locating;
@property (assign, nonatomic) BOOL locationSuccessful;
@property BOOL locationAllowed;

- (void) startUpdates;
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void) cancelUpdates;
- (BOOL) locationEnabledAndAllowed;
- (CLLocationAccuracy) desiredAccuracy;
- (double) desiredPrecision;

- (void)updateLocation:(void(^)(CLLocation* location, NSError* error))completion;

+ (MCMStatsLocatorService *) sharedInstance;

@end
