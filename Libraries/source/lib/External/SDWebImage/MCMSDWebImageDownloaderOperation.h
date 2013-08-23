/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "MCMSDWebImageDownloader.h"
#import "MCMSDWebImageOperation.h"

@interface MCMSDWebImageDownloaderOperation : NSOperation <MCMSDWebImageOperation>

@property (strong, nonatomic, readonly) NSURLRequest *request;
@property (assign, nonatomic, readonly) MCMSDWebImageDownloaderOptions options;

- (id)initWithRequest:(NSURLRequest *)request
              options:(MCMSDWebImageDownloaderOptions)options
             progress:(SDWebImageDownloaderProgressBlock)progressBlock
            completed:(SDWebImageDownloaderCompletedBlock)completedBlock
            cancelled:(void (^)())cancelBlock;

@end
