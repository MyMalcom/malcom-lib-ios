/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "MCMSDWebImageCompat.h"
#import "MCMSDWebImageDownloaderDelegate.h"
#import "MCMSDWebImageManagerDelegate.h"
#import "MCMSDImageCacheDelegate.h"

typedef enum
{
    MCMSDWebImageRetryFailed = 1 << 0,
    MCMSDWebImageLowPriority = 1 << 1,
    MCMSDWebImageCacheMemoryOnly = 1 << 2,
    MCMSDWebImageProgressiveDownload = 1 << 3
} MCMSDWebImageOptions;

#if NS_BLOCKS_AVAILABLE
typedef void(^MCMSDWebImageSuccessBlock)(UIImage *image, BOOL cached);
typedef void(^MCMSDWebImageFailureBlock)(NSError *error);
#endif

/**
 * The MCMSDWebImageManager is the class behind the UIImageView+WebCache category and likes.
 * It ties the asynchronous downloader (MCMSDWebImageDownloader) with the image cache store (MCMSDImageCache).
 * You can use this class directly to benefit from web image downloading with caching in another context than
 * a UIView.
 *
 * Here is a simple example of how to use MCMSDWebImageManager:
 *
 *  MCMSDWebImageManager *manager = [MCMSDWebImageManager sharedManager];
 *  [manager downloadWithURL:imageURL
 *                  delegate:self
 *                   options:0
 *                   success:^(UIImage *image, BOOL cached)
 *                   {
 *                       // do something with image
 *                   }
 *                   failure:nil];
 */
@interface MCMSDWebImageManager : NSObject <MCMSDWebImageDownloaderDelegate, MCMSDImageCacheDelegate>
{
    NSMutableArray *downloadInfo;
    NSMutableArray *downloadDelegates;
    NSMutableArray *downloaders;
    NSMutableArray *cacheDelegates;
    NSMutableArray *cacheURLs;
    NSMutableDictionary *downloaderForURL;
    NSMutableArray *failedURLs;
}

#if NS_BLOCKS_AVAILABLE
typedef NSString *(^CacheKeyFilter)(NSURL *url);

/**
 * The cache filter is a block used each time MCMSDWebManager need to convert an URL into a cache key. This can
 * be used to remove dynamic part of an image URL.
 *
 * The following example sets a filter in the application delegate that will remove any query-string from the
 * URL before to use it as a cache key:
 *
 * 	[[MCMSDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url)
 *	{
 *	    url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
 *	    return [url absoluteString];
 *	}];
 */
@property (strong) CacheKeyFilter cacheKeyFilter;
#endif


/**
 * Returns global MCMSDWebImageManager instance.
 *
 * @return MCMSDWebImageManager shared instance
 */
+ (id)sharedManager;

- (UIImage *)imageWithURL:(NSURL *)url __attribute__ ((deprecated));

/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url The URL to the image
 * @param delegate The delegate object used to send result back
 * @see [MCMSDWebImageManager downloadWithURL:delegate:options:userInfo:]
 * @see [MCMSDWebImageManager downloadWithURL:delegate:options:userInfo:success:failure:]
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id<MCMSDWebImageManagerDelegate>)delegate;

/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url The URL to the image
 * @param delegate The delegate object used to send result back
 * @param options A mask to specify options to use for this request
 * @see [MCMSDWebImageManager downloadWithURL:delegate:options:userInfo:]
 * @see [MCMSDWebImageManager downloadWithURL:delegate:options:userInfo:success:failure:]
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id<MCMSDWebImageManagerDelegate>)delegate options:(MCMSDWebImageOptions)options;

/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url The URL to the image
 * @param delegate The delegate object used to send result back
 * @param options A mask to specify options to use for this request
 * @param info An NSDictionnary passed back to delegate if provided
 * @see [MCMSDWebImageManager downloadWithURL:delegate:options:success:failure:]
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id<MCMSDWebImageManagerDelegate>)delegate options:(MCMSDWebImageOptions)options userInfo:(NSDictionary *)info;

// use options:MCMSDWebImageRetryFailed instead
- (void)downloadWithURL:(NSURL *)url delegate:(id<MCMSDWebImageManagerDelegate>)delegate retryFailed:(BOOL)retryFailed __attribute__ ((deprecated));
// use options:MCMSDWebImageRetryFailed|MCMSDWebImageLowPriority instead
- (void)downloadWithURL:(NSURL *)url delegate:(id<MCMSDWebImageManagerDelegate>)delegate retryFailed:(BOOL)retryFailed lowPriority:(BOOL)lowPriority __attribute__ ((deprecated));

#if NS_BLOCKS_AVAILABLE
/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url The URL to the image
 * @param delegate The delegate object used to send result back
 * @param options A mask to specify options to use for this request
 * @param success A block called when image has been retrived successfuly
 * @param failure A block called when couldn't be retrived for some reason
 * @see [MCMSDWebImageManager downloadWithURL:delegate:options:]
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id)delegate options:(MCMSDWebImageOptions)options success:(MCMSDWebImageSuccessBlock)success failure:(MCMSDWebImageFailureBlock)failure;

/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url The URL to the image
 * @param delegate The delegate object used to send result back
 * @param options A mask to specify options to use for this request
 * @param info An NSDictionnary passed back to delegate if provided
 * @param success A block called when image has been retrived successfuly
 * @param failure A block called when couldn't be retrived for some reason
 * @see [MCMSDWebImageManager downloadWithURL:delegate:options:]
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id)delegate options:(MCMSDWebImageOptions)options userInfo:(NSDictionary *)info success:(MCMSDWebImageSuccessBlock)success failure:(MCMSDWebImageFailureBlock)failure;
#endif

/**
 * Cancel all pending download requests for a given delegate
 *
 * @param delegate The delegate to cancel requests for
 */
- (void)cancelForDelegate:(id<MCMSDWebImageManagerDelegate>)delegate;

/**
 * Cancel all current opreations
 */
- (void)cancelAll;

@end
