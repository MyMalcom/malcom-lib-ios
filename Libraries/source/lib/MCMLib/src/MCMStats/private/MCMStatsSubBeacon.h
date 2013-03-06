//
//  SubBeacon.h
//

#import <Foundation/Foundation.h>


@interface MCMStatsSubBeacon : NSObject {

@private NSString *name_;               //Sub-beacon name
@private NSString *type_;               //Sub-beacon name
@private NSMutableDictionary *params_;  //Sub-beacon params
@private NSDate *startedOn_;            //Sub-beacon start
@private NSDate *stoppedOn_;            //Sub-beacon end
		
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSMutableDictionary *params;
@property (nonatomic, retain) NSDate *startedOn;	
@property (nonatomic, retain) NSDate *stoppedOn;	

/**
 Init method
 @param beaconName
 */
- (id)initWithName:(NSString *)beaconName;

/**
 Init method
 @param beaconName
 @param paramsDictionary
 @param type internal reference to sort subbeacons
 */
- (id)initWithName:(NSString *)beaconName type:(NSString *)type andParams:(NSDictionary *)paramsDictionary;

/**
 Method that return a dictionary with subbeacon data
 @return NSDictionary
 */
- (NSDictionary *) getJsonObject;

@end
