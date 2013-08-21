/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+MCMWebCache.h"
#import "objc/runtime.h"

static char operationKey;
static char operationArrayKey;

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(MCMSDWebImageOptions)options
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(MCMSDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(MCMSDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock
{
    [self cancelCurrentImageLoad];

    self.image = placeholder;
    
    if (url)
    {
        __weak UIImageView *wself = self;
        id<MCMSDWebImageOperation> operation = [MCMSDWebImageManager.sharedManager downloadWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, MCMSDImageCacheType cacheType, BOOL finished)
        {
            if (!wself) return;
            dispatch_main_sync_safe(^
            {
                __strong UIImageView *sself = wself;
                if (!sself) return;
                if (image)
                {
                    sself.image = image;
                    [sself setNeedsLayout];
                }
                if (completedBlock && finished)
                {
                    completedBlock(image, error, cacheType);
                }
            });
        }];
        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setAnimationImagesWithURLs:(NSArray *)arrayOfURLs
{
    [self cancelCurrentArrayLoad];
    __weak UIImageView *wself = self;

    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];

    for (NSURL *logoImageURL in arrayOfURLs)
    {
        id<MCMSDWebImageOperation> operation = [MCMSDWebImageManager.sharedManager downloadWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, MCMSDImageCacheType cacheType, BOOL finished)
        {
            if (!wself) return;
            dispatch_main_sync_safe(^
            {
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image)
                {
                    NSMutableArray *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages)
                    {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];

                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }

    objc_setAssociatedObject(self, &operationArrayKey, [NSArray arrayWithArray:operationsArray], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cancelCurrentImageLoad
{
    // Cancel in progress downloader from queue
    id<MCMSDWebImageOperation> operation = objc_getAssociatedObject(self, &operationKey);
    if (operation)
    {
        [operation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)cancelCurrentArrayLoad
{
    // Cancel in progress downloader from queue
    NSArray *operations = objc_getAssociatedObject(self, &operationArrayKey);
    for (id<MCMSDWebImageOperation> operation in operations)
    {
        if (operation)
        {
            [operation cancel];
        }
    }
    objc_setAssociatedObject(self, &operationArrayKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
