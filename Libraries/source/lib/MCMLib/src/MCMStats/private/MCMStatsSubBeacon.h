//
//  SubBeacon.h
//

#import <Foundation/Foundation.h>


@interface MCMStatsSubBeacon : NSObject {

@private NSString *name_;
@private NSDate *startedOn_;	
@private NSDate *stoppedOn_;	
		
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *startedOn;	
@property (nonatomic, retain) NSDate *stoppedOn;	

- (id)initWithName:(NSString *)beaconName;
- (NSDictionary *) getJsonObject;

@end
