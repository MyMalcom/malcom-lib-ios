/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+MCMWebCache.h"

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(MCMSDWebImageOptions)options
{
    MCMSDWebImageManager *manager = [MCMSDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    self.image = placeholder;

    if (url)
    {
        [manager downloadWithURL:url delegate:self options:options];
    }
}

#if NS_BLOCKS_AVAILABLE
- (void)setImageWithURL:(NSURL *)url success:(MCMSDWebImageSuccessBlock)success failure:(MCMSDWebImageFailureBlock)failure;
{
    [self setImageWithURL:url placeholderImage:nil success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder success:(MCMSDWebImageSuccessBlock)success failure:(MCMSDWebImageFailureBlock)failure;
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(MCMSDWebImageOptions)options success:(MCMSDWebImageSuccessBlock)success failure:(MCMSDWebImageFailureBlock)failure;
{
    MCMSDWebImageManager *manager = [MCMSDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    self.image = placeholder;

    if (url)
    {
        [manager downloadWithURL:url delegate:self options:options success:success failure:failure];
    }
}
#endif

- (void)cancelCurrentImageLoad
{
    @synchronized(self)
    {
        [[MCMSDWebImageManager sharedManager] cancelForDelegate:self];
    }
}

- (void)webImageManager:(MCMSDWebImageManager *)imageManager didProgressWithPartialImage:(UIImage *)image forURL:(NSURL *)url
{
    self.image = image;
    [self setNeedsLayout];
}

- (void)webImageManager:(MCMSDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    self.image = image;
    [self setNeedsLayout];
}

@end
