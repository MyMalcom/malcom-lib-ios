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
#import "MCMKeychainItemWrapper.h"

#define kMalcomIdentifier @"Malcom"
#define kMalcomAccessGroup @"MALCOM.com.malcom.lib"
#define kMalcomCrashControl @"Malcom_crash_control_init"

@interface MCMStatsManager ()

@property (atomic, assign) bool appCrashed;

- (void) sendToAwsSqs;
- (NSString *) getJSON;
- (NSArray *) subbeaconsJsonObject;
+ (void) addToJSONCache:(NSString *)json;
+ (NSString *) getCachedJSONForObject:(NSInteger)pos;
+ (NSArray *) getCachedJSON;

/**
 Process the beacon response to store the internal id into the keychain
 */
+ (void)processBeaconResponse:(NSDictionary *)json;

/**
 Gets the internal id from the keychain
 */
+ (NSString *)getMalcomInternalIdentifier;

+ (void)initAppCrashControl;

+ (void)endAppCrashControl;

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
    
    // Crash control
    [[MCMStatsManager sharedInstance] initAppCrashControl];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[MCMStatsManager sharedInstance] selector:@selector(endAppCrashControl)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
	
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
        [self endSubBeaconWithName:subName andParams:nil];
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


- (void)startSubBeaconWithName:(NSString *) beaconName forType:(NSString*)type andParams: (NSDictionary *) paramsDictionary timeSession:(BOOL)trackSession
{
	MCMStatsSubBeacon *subbeacon = [[MCMStatsSubBeacon alloc] initWithName:beaconName type:type andParams:paramsDictionary];
    subbeacon.startedOn = [NSDate date];
    
	if (trackSession) {
        //We add the subbeacon to dictionary in order to search it later and stablish the end time
		[subbeaconsDictionary_ setObject:subbeacon forKey:beaconName];
	}else{
        //If not track session means that is a unique event without time
        subbeacon.stoppedOn = [NSDate date];
    }
		
	[subbeaconsArray_ addObject:subbeacon];
    [subbeacon release];
}

- (void)endSubBeaconWithName:(NSString *) beaconName andParams: (NSDictionary *) paramsDictionary
{
	MCMStatsSubBeacon *subbeacon = [subbeaconsDictionary_ valueForKey:beaconName];
	if (subbeacon != nil ) {
		subbeacon.stoppedOn =[NSDate date];
	}
    
    //Check if the new param dictionary has some value setted in previous one and update it
    if (paramsDictionary)
    {
        for (NSString *key in [paramsDictionary allKeys])
        {
            [subbeacon.params setValue:[paramsDictionary valueForKey:key] forKey:key];
        }
    }
    
    [subbeaconsDictionary_ removeObjectForKey:beaconName];
}

+ (void)setTags:(NSArray *)tags {
	
    [[NSUserDefaults standardUserDefaults] setObject:tags forKey:@"mcm_tags"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
}

+ (NSArray *)getTags {
    
	return [[NSUserDefaults standardUserDefaults] arrayForKey:@"mcm_tags"];
    
}

+ (void)addTag:(NSString *)tagName{
    NSMutableArray *tags = [NSMutableArray arrayWithArray:[self getTags]];
    
    if (![[self getTags] containsObject:tagName]) {
        [tags addObject:tagName];
        
        [self setTags:tags];
    }
}

+ (void)removeTag:(NSString *)tagName{
    NSMutableArray *newTags = [NSMutableArray arrayWithCapacity:1];
    
    if ([[self getTags] containsObject:tagName]) {
        for (NSString *tag in [self getTags]) {
            if (![tag isEqualToString:tagName]) {
                [newTags addObject:tag];
            }
        }
        
        //Sets the new array without the tag
        [self setTags:newTags];
    }
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
    
    //if ((status==kReachableViaWiFi) || ((status==kReachableViaWWAN) && (useOnlyWifi_==NO)) ){
    //useOnlyWifi_ flag disabled. 
    if ((status==kReachableViaWiFi) || (status==kReachableViaWWAN)){
        
        NSArray *cacheJsons = [[self class] getCachedJSON];
        NSString *stringToSend = [cacheJsons componentsJoinedByString:@"\n"];
        
        [MCMLog log:[NSString stringWithFormat:@"Malcom MCMStats - MCMStatsManager Beacon sent: %@", stringToSend] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        
        NSURL *url = [NSURL URLWithString:[[MCMCoreManager sharedInstance] malcomUrlForPath:kMCMStatsBeaconsAPIPath]];
                        
        MCMCoreAPIRequest *request = [[MCMCoreAPIRequest alloc] initWithURL:url];
        [request appendPostData:[stringToSend dataUsingEncoding:NSUTF8StringEncoding]];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request startSynchronous];
        NSError *error = [request error];
                
        if ((!error) && ([request responseStatusCode]<402)) {
            // Process the beacon's request response 
            [MCMStatsManager processBeaconResponse:[NSJSONSerialization JSONObjectWithData:[request responseData]
                                                                         options:kNilOptions
                                                                           error:nil]];
            
            [[self class] clearCache];
        }
        else {
            
            [MCMLog log:[NSString stringWithFormat:@"Malcom MCMStats - MCMStatsManager Error sending statistics: %@", [request responseStatusMessage]] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
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
    
	//[self startSubBeaconWithName:@"cerrando" timeSession:false];
    
    //NSString *tags = [MCMNotificationUtils formatApnsTagString:[[NSUserDefaults standardUserDefaults] arrayForKey:@"mcm_tags"]];
    NSString *timeZone = [MCMCoreUtils userTimezone];
    NSString *userMetadata = [[NSUserDefaults standardUserDefaults] stringForKey:@"mcm_user_metadata"];
    NSArray *tagsArray = [MCMStatsManager getTags];
    
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								[MCMCoreUtils applicationVersion], @"app_version",
                                MCMVersionSDK, @"lib_version",
								applicationCode_, @"application_code",
                                userMetadata?userMetadata:@"", @"user_metadata",
								[MCMCoreUtils machinePlatformName], @"device_model",
								[MCMCoreUtils systemVersion], @"device_os",
                                [MCMCoreUtils platform], @"device_platform",
								[NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithInt:(int) location_.horizontalAccuracy], @"accuracy",
								 [NSNumber numberWithDouble:location_.coordinate.latitude], @"latitude",
								 [NSNumber numberWithDouble:location_.coordinate.longitude], @"longitude",
								 nil], @"location",
								[NSNumber numberWithDouble:[startedOn_ timeIntervalSince1970]], @"started_on",
								[NSNumber numberWithDouble:[stoppedOn_ timeIntervalSince1970]], @"stopped_on",
								[MCMCoreUtils uniqueIdentifier], @"udid",
								[MCMCoreUtils currentLanguage], @"language",
                                [MCMCoreUtils languageDeviceCountryCode], @"country",
                                city_?city_:@"", @"city",
                                [MCMCoreUtils carrierName], @"carrier",
                                tagsArray?tagsArray:@"", @"tags",
                                timeZone, @"time_zone",
								[self subbeaconsJsonObject], @"subbeacons",
								nil];
    
    //If there was a crash, send it to malcom server
    if(self.appCrashed){
        [dictionary setValue:@"true" forKey:@"crash"];
    }

    //Adds the advertising identifier for IOS7 migration
    IF_IOS6_OR_GREATER (
       [dictionary setValue:[MCMCoreUtils deviceIdentifier] forKey:@"identifier"]; 
    )
    
    //Adds the malcom internal identifier if exists
    NSString *internalIdentifier = [MCMStatsManager getMalcomInternalIdentifier];
    if (![internalIdentifier isEqualToString:@""]) {
        [dictionary setValue:internalIdentifier forKey:@"internalId"];
    }
    
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

+ (void)processBeaconResponse:(NSDictionary *)json {
    if ((json != nil) && [json objectForKey:@"internalId"]) {
        MCMLog(@"Received internalId: %@",[json objectForKey:@"internalId"]);
        
        MCMKeychainItemWrapper *wrapper = [[MCMKeychainItemWrapper alloc] initWithIdentifier:kMalcomIdentifier
                                                                                 accessGroup:kMalcomAccessGroup];
        
        [wrapper setObject:[json objectForKey:@"internalId"] forKey:kSecValueData];
    }
}

+ (NSString *)getMalcomInternalIdentifier {
    NSString *identifier = @"";
    MCMKeychainItemWrapper *wrapper = [[MCMKeychainItemWrapper alloc] initWithIdentifier:kMalcomIdentifier
                                                                             accessGroup:kMalcomAccessGroup];
    if ([wrapper objectForKey:(id)(kSecValueData)]) {
        identifier = [wrapper objectForKey:(id)(kSecValueData)];
    }
    
    return identifier;
}


- (void)initAppCrashControl {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.appCrashed = NO;
    
    if ([defaults boolForKey:kMalcomCrashControl]) {
        self.appCrashed = YES;
    }
    
    [defaults setBool:YES forKey:kMalcomCrashControl];
    
    [defaults synchronize];
}

- (void)endAppCrashControl {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:NO forKey:kMalcomCrashControl];
    
    [defaults synchronize];
}

@end

