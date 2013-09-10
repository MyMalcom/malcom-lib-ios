/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "MCMSDWebImageCompat.h"

@class MCMSDWebImageDownloader;

/**
 * Delegate protocol for MCMSDWebImageDownloader
 */
@protocol MCMSDWebImageDownloaderDelegate <NSObject>

@optional

- (void)imageDownloaderDidFinish:(MCMSDWebImageDownloader *)downloader;

/**
 * Called repeatedly while the image is downloading when [MCMSDWebImageDownloader progressive] is enabled.
 *
 * @param downloader The MCMSDWebImageDownloader instance
 * @param image The partial image representing the currently download portion of the image
 */
- (void)imageDownloader:(MCMSDWebImageDownloader *)downloader didUpdatePartialImage:(UIImage *)image;

/**
 * Called when download completed successfuly.
 *
 * @param downloader The MCMSDWebImageDownloader instance
 * @param image The downloaded image object
 */
- (void)imageDownloader:(MCMSDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image;

/**
 * Called when an error occurred
 *
 * @param downloader The MCMSDWebImageDownloader instance
 * @param error The error details
 */
- (void)imageDownloader:(MCMSDWebImageDownloader *)downloader didFailWithError:(NSError *)error;

@end
