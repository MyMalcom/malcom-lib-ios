//
//  MCMStatsSubBeacon.m
//

#import "MCMStatsSubBeacon.h"
#import "MCMStatsDefines.h"


@implementation MCMStatsSubBeacon

@synthesize name = name_;
@synthesize params = params_;
@synthesize type = type_;
@synthesize startedOn = startedOn_;	
@synthesize stoppedOn = stoppedOn_;

- (id)initWithName:(NSString *)beaconName 
{
	self = [super init];
	if (self != nil)
	{
		self.name = beaconName;
        params_ = [[NSMutableDictionary alloc] initWithCapacity:1];
        self.type= TYPE_CUSTOM;
	}
	return self;
}

- (id)initWithName:(NSString *)beaconName type:(NSString *)type andParams:(NSDictionary *)paramsDictionary
{
	self = [super init];
	if (self != nil)
	{
		self.name = beaconName;
        self.type = type;
        if (paramsDictionary) {
            params_ = [[NSMutableDictionary alloc] initWithDictionary: paramsDictionary];
        }else{
            params_ = [[NSMutableDictionary alloc] initWithCapacity:1];
        }
        
	}
	return self;
}

- (NSDictionary *) getJsonObject 
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			name_, @"name",
            type_!=nil?type_:TYPE_CUSTOM, @"type",
            params_, @"parameters",
			[NSNumber numberWithDouble:[startedOn_ timeIntervalSince1970]], @"started_on",
			[NSNumber numberWithDouble:[stoppedOn_ timeIntervalSince1970]], @"stopped_on",
			nil];
}

- (void)dealloc
{
    [params_ release];
	
	[super dealloc];
}

@end
