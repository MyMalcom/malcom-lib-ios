//
//  SDImageCacheDelegate.h
//  Dailymotion
//
//  Created by Olivier Poitrey on 16/09/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "MCMSDWebImageCompat.h"

@class MCMSDImageCache;

/**
 * Delegate protocol for MCMSDImageCache
 */
@protocol MCMSDImageCacheDelegate <NSObject>

@optional

/**
 * Called when [MCMSDImageCache queryDiskCacheForKey:delegate:userInfo:] retrived the image from cache
 *
 * @param imageCache The cache store instance
 * @param image The requested image instance
 * @param key The requested image cache key
 * @param info The provided user info dictionary
 */
- (void)imageCache:(MCMSDImageCache *)imageCache didFindImage:(UIImage *)image forKey:(NSString *)key userInfo:(NSDictionary *)info;

/**
 * Called when [MCMSDImageCache queryDiskCacheForKey:delegate:userInfo:] did not find the image in the cache
 *
 * @param imageCache The cache store instance
 * @param key The requested image cache key
 * @param info The provided user info dictionary
 */
- (void)imageCache:(MCMSDImageCache *)imageCache didNotFindImageForKey:(NSString *)key userInfo:(NSDictionary *)info;

@end
