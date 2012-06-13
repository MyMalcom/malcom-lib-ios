//
//  MCMStatsSubBeacon.m
//

#import "MCMStatsSubBeacon.h"


@implementation MCMStatsSubBeacon

@synthesize name = name_;
@synthesize startedOn = startedOn_;	
@synthesize stoppedOn = stoppedOn_;

- (id)initWithName:(NSString *)beaconName 
{
	self = [super init];
	if (self != nil)
	{
		self.name = beaconName;
	}
	return self;
}

- (NSDictionary *) getJsonObject 
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			name_, @"name",
			[NSNumber numberWithDouble:[startedOn_ timeIntervalSince1970]], @"started_on",
			[NSNumber numberWithDouble:[stoppedOn_ timeIntervalSince1970]], @"stopped_on",
			nil];
}

@end
