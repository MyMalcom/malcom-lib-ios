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

typedef void(^CompletionBlock)(CLLocation* location, NSError* error);

@interface MCMStatsLocatorService ()

@property (nonatomic, copy) CompletionBlock completionBlock;

@end

@implementation MCMStatsLocatorService SYNTHESIZE_SINGLETON_FOR_CLASS(MCMStatsLocatorService);

@synthesize currentLocation, locating, locationSuccessful, locationAllowed;

- (id) init {
	self = [super init];
	if (self != nil) {
		locationManager = [[[CLLocationManager alloc] init] retain];
		locationManager.delegate = self; // Tells the location manager to send updates to this object
		self.currentLocation = nil;
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

- (void)updateLocation:(void(^)(CLLocation* location, NSError* error))completion {
    
	self.completionBlock = completion;
    
    [self startUpdates];
}

#pragma mark - CLLocationManagerDelegate methods
// Delegate method from the CLLocationManagerDelegate protocol. Called when the location is updated
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
#if TARGET_IPHONE_SIMULATOR
    //Set the location for simulator
    newLocation = [[[CLLocation alloc] initWithLatitude:HARDCODED_LAT longitude:HARDCODED_LNG] autorelease];
    
    MCMLog(@"Hardcoded location: %f,%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
#endif
    
    //Check if there is not completition block to update the location
    if (self.completionBlock == nil) {
        
		[[MCMStatsManager sharedInstance] setLocation:newLocation];
		[self setCurrentLocation:newLocation];
        
    } else {
        
        //Stop the location updates
        [self cancelUpdates];
        
        //Calls the completition block with the location
        self.completionBlock(newLocation,nil);
    }
    
    Class klass = NSClassFromString(@"CLGeocoder");
    
    if (klass != nil) {
        
        CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
        [geocoder reverseGeocodeLocation:newLocation
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                                                      
                           if (error){
                               MCMLog(@"Geocode failed with error: %@", error);
                               return;
                           }
                           
                           if(placemarks && placemarks.count > 0){
                               //do something
                               CLPlacemark *topResult = [placemarks objectAtIndex:0];
                               
                               [[MCMStatsManager sharedInstance] setCity:[topResult locality]];
                               
                           }
                       }];
        
    }
    
    MCMLog(@"Location updated");
    
	// If it's a relatively recent event, turn off updates to save power
	NSDate* eventDate = newLocation.timestamp;
	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
	
	// Horizontal coordinates
	if (signbit(newLocation.horizontalAccuracy)) {
		// Negative accuracy means an invalid or unavailable measurement
		// CoreLocation returns positive for North & East, negative for South & West
		
        MCMLog(@"invalid or unavailable measurement");
		[self setLocationSuccessful:NO];
		return;
	}
	
	
	if (abs(howRecent) < 5.0 && newLocation.horizontalAccuracy < [self desiredPrecision]) //< 100)
	{
		// if its fresh stop updating
        MCMLog(@"stop updating location latitude %+.6f, longitude %+.6f\n, DesiredIndex:%d", newLocation.coordinate.latitude, newLocation.coordinate.longitude, desiredIndex);
        
		[manager stopUpdatingLocation];
		[self setLocationSuccessful:YES];
		[self setLocating: NO];
		if (desiredIndex < [desiredPrecisions count] - 1) { desiredIndex++; }
	} else
	{
		[self setLocationSuccessful:NO];
	}
    
}

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	MCMLog(@"Error updating location: %@", [error description]);
    
	//	[delegate localizationError: error];
	[self setLocationAllowed: NO];
	[self cancelUpdates];
    
    //Calls the completition block with the error
    if (self.completionBlock != nil) {
        
        self.completionBlock(nil,error);
        
    }
}


- (void) cancelUpdates {
	[locationManager stopUpdatingLocation];
	[self setLocating: NO];
    
    //    self.completionBlock = nil;
	
}

- (BOOL) locationEnabledAndAllowed {
    
    return [CLLocationManager locationServicesEnabled] && locationAllowed;
}

@end