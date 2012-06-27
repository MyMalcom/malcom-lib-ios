//
//  MSConversionTracker.h
//  SimpleAds
//
//  Created by Guillermo Fernandez on 12/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

// Based on MPAdConversionTracker.h

//
//  MPAdConversionTracker.h
//  MoPub
//
//  Created by Andrew He on 2/4/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "MSProtocolMediation.h"

BOOL flashPerformed(void);
BOOL performFlash(NSDictionary* context);

@interface MSConversionTracker : NSObject {

}

+ (MSConversionTracker *)sharedConversionTracker;

/*
 * Notify MediaSmart that the current user has opened the application corresponding to appID.
 */
- (void)reportConversionWith:(NSString*)optionalScheme ForEvent:(NSString *)event Number:(uint) number;




@end
