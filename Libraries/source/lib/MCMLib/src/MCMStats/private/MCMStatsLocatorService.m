//
// $Id: MCMStatsLocatorService.m 10377 2009-09-28 15:41:28Z ascandroli $
//
// Abstract: Singleton class used to talk to CoreLocation and send results back to
// the app's view controllers.
//
// http://developer.apple.com/iphone/library/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/AdvancedFeatures/chapter_11_section_3.html
//
// Singletons, AppDelegates and top-level data. SYNTHESIZE_SINGLETON_FOR_CLASS macro
// http://cocoawithlove.com/2008/11/singletons-appdelegates-and-top-level.html
// 

#import "MCMStatsLocatorService.h"
#import "MCMStatsManager.h"
#import "MCMCoreDefines.h"
#import "MCMLog.h"

#define HARDCODED_LAT 41.389939
#define HARDCODED_LNG 2.177603 
#define MIN_MOVEMENT 100

@implementation MCMStatsLocatorService SYNTHESIZE_SINGLETON_FOR_CLASS(MCMStatsLocatorService);

@synthesize currentLocation, locating, locationSuccessful, locationAllowed;

- (id) init {
	self = [super init];
	if (self != nil) {
		locationManager = [[[CLLocationManager alloc] init] retain];
		locationManager.delegate = self; // Tells the location manager to send updates to this object
		self.currentLocation = [[[CLLocation alloc] initWithLatitude:HARDCODED_LAT longitude:HARDCODED_LNG] autorelease];
		desiredPrecisions = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:10000], [NSNumber numberWithInt:4000], [NSNumber numberWithInt:2000],[NSNumber numberWithInt:MIN_MOVEMENT * 2], nil];
		desiredAccuracies = [[NSArray alloc] initWithObjects:[NSNumber numberWithDouble:kCLLocationAccuracyThreeKilometers], [NSNumber numberWithDouble:kCLLocationAccuracyKilometer], [NSNumber numberWithDouble:kCLLocationAccuracyHundredMeters],[NSNumber numberWithDouble:kCLLocationAccuracyBest], nil];
		self.locationSuccessful = NO;
		self.locationAllowed = YES;
		self.locating = YES;
		desiredIndex = 0;
	}
	return self;
}

- (void) startUpdates {
	
	locationManager.desiredAccuracy = [self desiredAccuracy];
	// Set a movement threshold for new events
	locationManager.distanceFilter = kCLDistanceFilterNone;
	[self setLocating: YES];
	[locationManager startUpdatingLocation];
	
}

- (CLLocationAccuracy) desiredAccuracy {
	return [[desiredAccuracies objectAtIndex:desiredIndex] doubleValue];
}

- (double) desiredPrecision {
	return	[[desiredPrecisions objectAtIndex:desiredIndex] doubleValue];
}

// Delegate method from the CLLocationManagerDelegate protocol. Called when the location is updated
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    Class klass = NSClassFromString(@"CLGeocoder");
    
    if (klass != nil) {
        
        CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
        [geocoder reverseGeocodeLocation:newLocation 
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           
                           [MCMLog log:@"reverseGeocodeLocation:completionHandler: Completion Handler called!" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
                           
                           if (error){
                               
                               [MCMLog log:[NSString stringWithFormat:@"Geocode failed with error: %@", error] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
                               return;
                               
                           }
                           
                           if(placemarks && placemarks.count > 0)
                               
                           {
                               //do something   
                               CLPlacemark *topResult = [placemarks objectAtIndex:0];
                               
                               [[MCMStatsManager sharedInstance] setCity:[topResult locality]];
                               
                           }
                       }];
        
    }
    
	[MCMLog log:[NSString stringWithFormat:@"latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude] 
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
	
    [MCMLog log:[NSString stringWithFormat:@"horizontalAccuracy: %+.6f, verticalAccuracy %+.6f, bestAccuracy %+.6f", newLocation.horizontalAccuracy, newLocation.verticalAccuracy, kCLLocationAccuracyBest] 
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
	
	// If it's a relatively recent event, turn off updates to save power
	NSDate* eventDate = newLocation.timestamp;
	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
	
	// Horizontal coordinates
	if (signbit(newLocation.horizontalAccuracy)) {
		// Negative accuracy means an invalid or unavailable measurement
		// CoreLocation returns positive for North & East, negative for South & West
		
        [MCMLog log:@"invalid or unavailable measurement" inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
		[self setLocationSuccessful:NO];
		return;
	} 
	
	
	if (abs(howRecent) < 5.0 && newLocation.horizontalAccuracy < [self desiredPrecision]) //< 100) 
	{
		// if its fresh stop updating
		[MCMLog log:[NSString stringWithFormat:@"stop updating location latitude %+.6f, longitude %+.6f\n, DesiredIndex:%d", newLocation.coordinate.latitude, newLocation.coordinate.longitude, desiredIndex] 
             inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
		[manager stopUpdatingLocation];
		[self setLocationSuccessful:YES];
		[self setLocating: NO];
		if (desiredIndex < [desiredPrecisions count] - 1) { desiredIndex++; }
	} else 
	{
		[self setLocationSuccessful:NO];
	}	
	
#if TARGET_IPHONE_SIMULATOR
		[[MCMStatsManager sharedInstance] setLocation:currentLocation];
		[self setCurrentLocation:currentLocation];
		[MCMLog log:[NSString stringWithFormat:@"Hardcoded location: %f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude] 
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
#else
		[[MCMStatsManager sharedInstance] setLocation:newLocation];	 
		[self setCurrentLocation:newLocation];
#endif

}

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	
    [MCMLog log:[NSString stringWithFormat:@"error updating location: %@", [error description]] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
	//	[delegate localizationError: error];
	[self setLocationAllowed: NO];
	[self cancelUpdates];
}


- (void) cancelUpdates {
	[locationManager stopUpdatingLocation];
	[self setLocating: NO];
	
}

- (BOOL) locationEnabledAndAllowed {
	return [locationManager locationServicesEnabled] && locationAllowed;
}

@end