//
//  MPAdapterMap.h
//  MoPub
//
//  Created by Andrew He on 1/26/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPAdapterMap : NSObject
{
	// Mapping of adapter class names to ad types (NSString -> NSString).
	NSDictionary *_map;
}

/*
 * Get the shared adapter map.
 */
+ (id)sharedAdapterMap;

/*
 * Convenience methods for getting the NSString or Class representation for a certain ad type.
 */
- (NSString *)classStringForAdapterType:(NSString *)type;
- (Class)classForAdapterType:(NSString *)type;

@end