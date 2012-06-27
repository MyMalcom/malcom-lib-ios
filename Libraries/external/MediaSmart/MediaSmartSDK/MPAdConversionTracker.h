//
//  MPAdConversionTracker.h
//  MoPub
//
//  Created by Andrew He on 2/4/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MPAdConversionTracker : NSObject 
{
}

+ (MPAdConversionTracker *)sharedConversionTracker;

/*
 * Notify MoPub that the current user has opened the application corresponding to appID.
 */
- (void)reportApplicationOpenForApplicationID:(NSString *)appID;

@end
