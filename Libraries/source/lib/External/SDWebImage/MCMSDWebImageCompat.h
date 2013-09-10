/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Jamie Pinkham
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <TargetConditionals.h>

#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#ifndef UIImage
#define UIImage NSImage
#endif
#ifndef UIImageView
#define UIImageView NSImageView
#endif
#else
#import <UIKit/UIKit.h>
#endif

#if ! __has_feature(objc_arc)
#define MCMSDWIAutorelease(__v) ([__v autorelease]);
#define MCMSDWIReturnAutoreleased MCMSDWIAutorelease

#define MCMSDWIRetain(__v) ([__v retain]);
#define MCMSDWIReturnRetained MCMSDWIRetain

#define MCMSDWIRelease(__v) ([__v release]);
#define MCMSDWISafeRelease(__v) ([__v release], __v = nil);
#define MCMSDWISuperDealoc [super dealloc];

#define MCMSDWIWeak
#else
// -fobjc-arc
#define MCMSDWIAutorelease(__v)
#define MCMSDWIReturnAutoreleased(__v) (__v)

#define MCMSDWIRetain(__v)
#define MCMSDWIReturnRetained(__v) (__v)

#define MCMSDWIRelease(__v)
#define MCMSDWISafeRelease(__v) (__v = nil);
#define MCMSDWISuperDealoc

#define MCMSDWIWeak __unsafe_unretained
#endif


NS_INLINE UIImage *MCMSDScaledImageForPath(NSString *path, NSObject *imageOrData)
{
    if (!imageOrData)
    {
        return nil;
    }

    UIImage *image = nil;
    if ([imageOrData isKindOfClass:[NSData class]])
    {
        image = [[UIImage alloc] initWithData:(NSData *)imageOrData];
    }
    else if ([imageOrData isKindOfClass:[UIImage class]])
    {
        image = MCMSDWIReturnRetained((UIImage *)imageOrData);
    }
    else
    {
        return nil;
    }

    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        CGFloat scale = 1.0;
        if (path.length >= 8)
        {
            // Search @2x. at the end of the string, before a 3 to 4 extension length (only if key len is 8 or more @2x. + 4 len ext)
            NSRange range = [path rangeOfString:@"@2x." options:0 range:NSMakeRange(path.length - 8, 5)];
            if (range.location != NSNotFound)
            {
                scale = 2.0;
            }
        }

        UIImage *scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
        MCMSDWISafeRelease(image)
        image = scaledImage;
    }

    return MCMSDWIReturnAutoreleased(image);
}
