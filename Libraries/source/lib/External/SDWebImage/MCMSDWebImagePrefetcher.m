/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "MCMSDWebImagePrefetcher.h"
#import "MCMSDWebImageManager.h"

@interface MCMSDWebImagePrefetcher ()
@property (nonatomic, retain) NSArray *prefetchURLs;
@end

@implementation MCMSDWebImagePrefetcher

static MCMSDWebImagePrefetcher *instance;

@synthesize prefetchURLs;
@synthesize maxConcurrentDownloads;
@synthesize options;

+ (MCMSDWebImagePrefetcher *)sharedImagePrefetcher
{
    if (instance == nil)
    {
        instance = [[MCMSDWebImagePrefetcher alloc] init];
        instance.maxConcurrentDownloads = 3;
        instance.options = (MCMSDWebImageLowPriority);
    }

    return instance;
}

- (void)startPrefetchingAtIndex:(NSUInteger)index withManager:(MCMSDWebImageManager *)imageManager
{
    if (index >= [self.prefetchURLs count]) return;
    _requestedCount++;
    [imageManager downloadWithURL:[self.prefetchURLs objectAtIndex:index] delegate:self options:self.options];
}

- (void)reportStatus
{
    NSUInteger total = [self.prefetchURLs count];
    NSLog(@"Finished prefetching (%d successful, %d skipped, timeElasped %.2f)", total - _skippedCount, _skippedCount, CFAbsoluteTimeGetCurrent() - _startedTime);
}

- (void)prefetchURLs:(NSArray *)urls
{
    [self cancelPrefetching]; // Prevent duplicate prefetch request
    _startedTime = CFAbsoluteTimeGetCurrent();
    self.prefetchURLs = urls;

    // Starts prefetching from the very first image on the list with the max allowed concurrency
    NSUInteger listCount = [self.prefetchURLs count];
    MCMSDWebImageManager *manager = [MCMSDWebImageManager sharedManager];
    for (NSUInteger i = 0; i < self.maxConcurrentDownloads && _requestedCount < listCount; i++)
    {
        [self startPrefetchingAtIndex:i withManager:manager];
    }
}

- (void)cancelPrefetching
{
    self.prefetchURLs = nil;
    _skippedCount = 0;
    _requestedCount = 0;
    _finishedCount = 0;
    [[MCMSDWebImageManager sharedManager] cancelForDelegate:self];
}

#pragma mark MCMSDWebImagePrefetcher (MCMSDWebImageManagerDelegate)

- (void)webImageManager:(MCMSDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    _finishedCount++;
    NSLog(@"Prefetched %d out of %d", _finishedCount, [self.prefetchURLs count]);

    if ([self.prefetchURLs count] > _requestedCount)
    {
        [self startPrefetchingAtIndex:_requestedCount withManager:imageManager];
    }
    else if (_finishedCount == _requestedCount)
    {
        [self reportStatus];
    }
}

- (void)webImageManager:(MCMSDWebImageManager *)imageManager didFailWithError:(NSError *)error
{
    _finishedCount++;
    NSLog(@"Prefetched %d out of %d (Failed)", _finishedCount, [self.prefetchURLs count]);

    // Add last failed
    _skippedCount++;

    if ([self.prefetchURLs count] > _requestedCount)
    {
        [self startPrefetchingAtIndex:_requestedCount withManager:imageManager];
    }
    else if (_finishedCount == _requestedCount)
    {
        [self reportStatus];
    }
}

- (void)dealloc
{
    self.prefetchURLs = nil;
    MCMSDWISuperDealoc;
}

@end
