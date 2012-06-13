//
//  MCMStatsManager.m
//
//  Created by Alejandro Scandroli on 16/09/09.
//  Copyright 2009 MMiP. All rights reserved.
//

#import "MCMStatsManager.h"
#import "MCMStats.h"
#import "MCMStatsDefines.h"

#import "MCMCore.h"
#import "MCMCoreDefines.h"

#import "MCMCJSONSerializer.h"
#import "MCMReachability.h"
#import "MCMNotificationUtils.h"

@interface MCMStatsManager (private)

- (void) sendToAwsSqs;
- (NSString *) getJSON;
- (NSArray *) subbeaconsJsonObject;
+ (void) addToJSONCache:(NSString *)json;
+ (NSString *) getCachedJSONForObject:(NSInteger)pos;
+ (NSArray *) getCachedJSON;

@end


@implementation MCMStatsManager SYNTHESIZE_SINGLETON_FOR_CLASS(MCMStatsManager);

@synthesize applicationCode = applicationCode_;
@synthesize startedOn = startedOn_;	
@synthesize stoppedOn = stoppedOn_;
@synthesize location = location_;
@synthesize useOnlyWifi = useOnlyWifi_;
@synthesize coreLocation = coreLocation_;
@synthesize city = city_;

+ (id)initAndStartBeaconWithApplicationCode:(NSString *)theApplicationCode useCoreLocation:(BOOL)coreLocation useOnlyWiFi:(BOOL)wifiState 
{
	[[MCMStatsManager sharedInstance] setApplicationCode:theApplicationCode];
    [[MCMStatsManager sharedInstance] setCoreLocation:coreLocation];
    [[MCMStatsManager sharedInstance] setUseOnlyWifi:wifiState];
	[[MCMStatsManager sharedInstance] startBeacon];
	
	return [MCMStatsManager sharedInstance];
}

- (void) dealloc {

    self.applicationCode=nil;
    self.startedOn=nil;	
    self.stoppedOn=nil;	
    self.location=nil;

    [subbeaconsArray_ release]; subbeaconsArray_=nil;
    [subbeaconsDictionary_ release]; subbeaconsDictionary_=nil;
    
    [super dealloc];
}

- (void)startBeacon 
{
    [subbeaconsArray_ release];
	subbeaconsArray_ = [[NSMutableArray alloc] init];
    [subbeaconsDictionary_ release];
	subbeaconsDictionary_ = [[NSMutableDictionary alloc] init];
	
	self.startedOn = [NSDate date];
    self.stoppedOn=nil;	
    if (self.coreLocation)
        [[MCMStatsLocatorService sharedInstance] startUpdates];
}

- (void) endBeacon 
{
    //Finish any subbeacons started that are still open
	NSArray *subbeacons = [subbeaconsDictionary_ allKeys];
	for (NSString *subName in subbeacons)
	{
        [self endSubBeaconWithName:subName];
	}

    //Set stop date
    if (self.stoppedOn==nil)
        self.stoppedOn = [NSDate date];
    
    //Send the data to SQS (or cache)
	[self sendToAwsSqs];

    //Stop updating position
    [[MCMStatsLocatorService sharedInstance] cancelUpdates];
    
    //Release memory
    [subbeaconsArray_ release]; subbeaconsArray_=nil;
    [subbeaconsDictionary_ release]; subbeaconsDictionary_=nil;
}


- (void)startSubBeaconWithName:(NSString *) beaconName timeSession:(BOOL)trackSession 
{
	MCMStatsSubBeacon *subbeacon = [[MCMStatsSubBeacon alloc] initWithName:beaconName];

	if (trackSession) 
	{
		subbeacon.startedOn = [NSDate date];
		[subbeaconsDictionary_ setObject:subbeacon forKey:beaconName];
	}
		
	[subbeaconsArray_ addObject:subbeacon];
    [subbeacon release];
}

- (void)endSubBeaconWithName:(NSString *) beaconName 
{
	MCMStatsSubBeacon *subbeacon = [subbeaconsDictionary_ valueForKey:beaconName];
	if (subbeacon != nil ) {
		subbeacon.stoppedOn =[NSDate date];
	}
    [subbeaconsDictionary_ removeObjectForKey:beaconName];
}

+ (void) clearCache{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMCMStatsCacheName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) setCoreLocation:(BOOL)coreLocation{
    
    [self willChangeValueForKey:@"coreLocation"];
    coreLocation_ = coreLocation;
    [self didChangeValueForKey:@"coreLocation"];

    //If the beacons already started, try to start or stop the locator service
    if (subbeaconsArray_!=nil){
        if (self.coreLocation)
            [[MCMStatsLocatorService sharedInstance] startUpdates];
        else
            [[MCMStatsLocatorService sharedInstance] cancelUpdates];
    }
}


#pragma mark --- Private methods ---

- (void) sendToAwsSqs
{
    //Safe data in cache
    [[self class] addToJSONCache:[self getJSON]];
    
    //Check network status
    MCMNetworkStatus status = [[MCMReachability reachabilityForInternetConnection] currentReachabilityStatus];    
    if ((status==kReachableViaWiFi) || ((status==kReachableViaWWAN) && (useOnlyWifi_==NO))){                
        
        NSArray *cacheJsons = [[self class] getCachedJSON];
        NSString *stringToSend = [cacheJsons componentsJoinedByString:@"\n"];
        
        NSURL *url = [NSURL URLWithString:[[MCMCoreManager sharedInstance] malcomUrlForPath:kMCMStatsBeaconsAPIPath]];
                        
        MCMCoreAPIRequest *request = [[MCMCoreAPIRequest alloc] initWithURL:url];
        [request appendPostData:[stringToSend dataUsingEncoding:NSUTF8StringEncoding]];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request startSynchronous];
        NSError *error = [request error];
                
        if ((!error) && ([request responseStatusCode]<402)) {
           [[self class] clearCache]; 
        }
        else {
            
            [MCMLog log:[NSString stringWithFormat:@"Error sending statistics: %@", [request responseStatusMessage]] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        }            
    }    
}


- (NSArray *) subbeaconsJsonObject 
{	
	NSMutableArray *subbeaconsJSON = [[NSMutableArray alloc] init];
	for (MCMStatsSubBeacon *sub in subbeaconsArray_)
	{
		[subbeaconsJSON addObject:[sub getJsonObject]];
	}
    	
	return [subbeaconsJSON autorelease];
}


- (NSString *) getJSON 
{
    
	[self startSubBeaconWithName:@"cerrando" timeSession:false];
    
    //NSString *tags = [MCMNotificationUtils formatApnsTagString:[[NSUserDefaults standardUserDefaults] arrayForKey:@"mcm_tags"]];
    NSString *timeZone = [MCMCoreUtils userTimezone];    
    
    
	NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
								[MCMCoreUtils applicationVersion], @"app_version",
								applicationCode_, @"application_code",
								[MCMCoreUtils machinePlatform], @"device_model",
								[MCMCoreUtils systemVersion], @"device_os",
                                [MCMCoreUtils platform], @"device_platform",
								[NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithInt:(int) location_.horizontalAccuracy], @"accuracy",
								 [NSNumber numberWithDouble:location_.coordinate.latitude], @"latitude",
								 [NSNumber numberWithDouble:location_.coordinate.longitude], @"longitude",
                                 city_, @"city",
								 nil], @"location",
								[NSNumber numberWithDouble:[startedOn_ timeIntervalSince1970]], @"started_on",
								[NSNumber numberWithDouble:[stoppedOn_ timeIntervalSince1970]], @"stopped_on",
								[MCMCoreUtils uniqueIdentifier], @"udid",
								[MCMCoreUtils currentLanguage], @"language",
                                [MCMCoreUtils languageDeviceCountryCode], @"country",
                                [MCMCoreUtils carrierName], @"carrier",
                                [[NSUserDefaults standardUserDefaults] arrayForKey:@"mcm_tags"], @"tags",	
                                timeZone, @"time_zone",
								[self subbeaconsJsonObject], @"subbeacons",
								nil];
	
    
	NSDictionary *jsonBeacon = [[NSDictionary alloc] initWithObjectsAndKeys:
								dictionary, @"beacon",
								nil];
    
	//Convert the dict in a string using the serializer. Note that different versions of serializers could exists, so protect by checking performSelector
	NSString *theBodyString = nil;
    id serializer = [MCMCJSONSerializer serializer];
    if ([serializer respondsToSelector:@selector(serializeObject:)]){
        theBodyString=(NSString *)[serializer performSelector:@selector(serializeObject:) withObject:jsonBeacon];
    }else if ([[MCMCJSONSerializer serializer] respondsToSelector:@selector(serializeObject:error:)]){        
        id ret = [serializer performSelector:@selector(serializeObject: error:) withObject:jsonBeacon];
        if ([ret isKindOfClass:[NSData class]]){
            theBodyString = [[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease];
        }
        else if ([ret isKindOfClass:[NSString class]]){
            theBodyString = ret;
        }
    }
    
	[dictionary release];
	[jsonBeacon release];
    
	return theBodyString;
}


+ (void) addToJSONCache:(NSString *)json{
    if (json==nil) return;
    
    //Add the new element
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[self getCachedJSON]];
    [mutableArray addObject:json];
    
    //Remove oldest if to many objects in the array
    while ([mutableArray count]>kMCMStatsCacheMaxElements){
        [mutableArray removeObjectAtIndex:0];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mutableArray forKey:kMCMStatsCacheName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) getCachedJSONForObject:(NSInteger)pos{
    NSArray *cacheArray = [self getCachedJSON];
    if ((pos<0) || ([cacheArray count]<=pos))
        return nil;
    
    return [cacheArray objectAtIndex:pos];    
}

+ (NSArray *) getCachedJSON{
    NSArray *cache=(NSArray *) [[NSUserDefaults standardUserDefaults] objectForKey:kMCMStatsCacheName];  
    
    if (cache==nil)
        return [NSArray array];
    else
        return cache;
}

@end

