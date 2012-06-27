//
//  MPGlobal.m
//  MoPub
//
//  Created by Andrew He on 5/5/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPGlobal.h"
#import "MPConstants.h"
#import <CommonCrypto/CommonDigest.h>
#import "OpenUDID.h"

NSString *MPReadUDIDFromDefaults();
void MPWriteUDIDToDefaults(NSString *UDID);
NSString *MPGenerateUDID();
NSString *MPSHA1Digest(NSString *string);

UIInterfaceOrientation MPInterfaceOrientation()
{
	return [UIApplication sharedApplication].statusBarOrientation;
}

UIWindow *MPKeyWindow()
{
    return [UIApplication sharedApplication].keyWindow;
}

CGFloat MPStatusBarHeight() {
    if ([UIApplication sharedApplication].statusBarHidden) return 0.0;
    
    UIInterfaceOrientation orientation = MPInterfaceOrientation();
    
    return UIInterfaceOrientationIsLandscape(orientation) ?
        CGRectGetWidth([UIApplication sharedApplication].statusBarFrame) :
        CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
}

CGRect MPApplicationFrame()
{
    CGRect frame = MPScreenBounds();
    
    frame.origin.y += MPStatusBarHeight();
    frame.size.height -= MPStatusBarHeight();
    
    return frame;
}

CGRect MPScreenBounds()
{
	CGRect bounds = [UIScreen mainScreen].bounds;
	
	if (UIInterfaceOrientationIsLandscape(MPInterfaceOrientation()))
	{
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	
	return bounds;
}

CGFloat MPDeviceScaleFactor()
{
	if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
		[[UIScreen mainScreen] respondsToSelector:@selector(scale)])
	{
		return [[UIScreen mainScreen] scale];
	}
	else return 1.0;
}

NSString *MPUserAgentString()
{
	static NSString *userAgent = nil;
	
    if (!userAgent) {
        UIWebView *webview = [[UIWebView alloc] init];
        userAgent = [[webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] copy];  
        [webview release];
    }
    return userAgent;
}

NSDictionary *MPDictionaryFromQueryString(NSString *query) {
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
	NSArray *queryElements = [query componentsSeparatedByString:@"&"];
	for (NSString *element in queryElements) {
		NSArray *keyVal = [element componentsSeparatedByString:@"="];
		NSString *key = [keyVal objectAtIndex:0];
		NSString *value = [keyVal lastObject];
		[queryDict setObject:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
					  forKey:key];
	}
	return queryDict;
}

NSString *MPHashedUDID()
{
	static NSString *cachedIdentifier = nil;
    
    if (cachedIdentifier) return cachedIdentifier;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    cachedIdentifier = [[userDefaults objectForKey:MOPUB_IDENTIFIER_DEFAULTS_KEY] retain];
    if (!cachedIdentifier)
    {
        cachedIdentifier = [MPGenerateUDID() retain];
        [userDefaults setObject:cachedIdentifier forKey:MOPUB_IDENTIFIER_DEFAULTS_KEY];
        [userDefaults synchronize];
    }
    
	return cachedIdentifier;
}

NSString *MPGenerateUDID()
{
    NSString *identifier;
    NSString *identifierLabel;
    
#if MOPUB_USE_OPENUDID
    identifierLabel = @"openudid";
    identifier = [OpenUDID value];
#else
    identifierLabel = @"sha";
    identifier = MPSHA1Digest([[UIDevice currentDevice] uniqueIdentifier]);
#endif
    
    return [NSString stringWithFormat:@"%@:%@", identifierLabel, [identifier uppercaseString]];
}

NSString *MPSHA1Digest(NSString *string)
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
    CC_SHA1([data bytes], [data length], digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}


////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CJSONDeserializer (MPAdditions)

+ (CJSONDeserializer *)deserializerWithNullObject:(id)obj
{
    CJSONDeserializer *deserializer = [CJSONDeserializer deserializer];
    //deserializer.nullObject = obj;
    return deserializer;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSString (MPAdditions)

- (NSString *)URLEncodedString
{
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																		   (CFStringRef)self,
																		   NULL,
																		   (CFStringRef)@"!*'();:@&=+$,/?%#[]<>",
																		   kCFStringEncodingUTF8);
	return [result autorelease];
}

@end
