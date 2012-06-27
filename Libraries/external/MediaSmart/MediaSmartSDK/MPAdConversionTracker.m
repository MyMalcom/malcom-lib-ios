//
//  MPAdConversionTracker.m
//  MoPub
//
//  Created by Andrew He on 2/4/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPAdConversionTracker.h"
#import "MPConstants.h"
#import "MPGlobal.h"
#import "MPLogging.h"

#define kUserAgentContextKey @"user-agent"
#define kApplicationIdContextKey @"app-id"

@interface MPAdConversionTracker (Internal)
- (void)reportApplicationOpenSynchronous:(NSDictionary *)context;
@end

@implementation MPAdConversionTracker

+ (MPAdConversionTracker *)sharedConversionTracker
{
	static MPAdConversionTracker *sharedConversionTracker;
	
	@synchronized(self)
	{
		if (!sharedConversionTracker)
			sharedConversionTracker = [[MPAdConversionTracker alloc] init];
		return sharedConversionTracker;
	}
}

- (void)reportApplicationOpenForApplicationID:(NSString *)appID
{
	// MPUserAgentString() must be called on the main thread, since it manipulates a UIWebView.
	NSString *userAgent = MPUserAgentString();
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 userAgent, kUserAgentContextKey,
							 appID, kApplicationIdContextKey, nil];
	
	[self performSelectorInBackground:@selector(reportApplicationOpenSynchronous:) 
						   withObject:context];
}

#pragma mark -
#pragma mark Internal

- (void)reportApplicationOpenSynchronous:(NSDictionary *)context
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] <= 0) {[pool release]; return;}

	
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *appOpenLogPath = [documentsDir stringByAppendingPathComponent:@"mopubAppOpen.log"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// The existence of mopubAppOpen.log tells us whether we have already reported this app open.
	if ([fileManager fileExistsAtPath:appOpenLogPath]) {[pool release]; return;}
	
	NSString *appID = [context objectForKey:kApplicationIdContextKey];
	NSString *userAgent = [context objectForKey:kUserAgentContextKey];
	
	NSString *appOpenUrlString = [NSString stringWithFormat:@"http://%@/m/open?v=8&udid=%@&id=%@",
								  HOSTNAME,
								  MPHashedUDID(),
								  appID];
	
	MPLogInfo(@"Reporting application did launch for the first time to MoPub: %@", appOpenUrlString);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:appOpenUrlString]];
	[request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	
	NSURLResponse *response;
	NSError *error = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request 
												 returningResponse:&response 
															 error:&error];
	
	if ((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200) && 
		([responseData length] > 0))
	{
		[fileManager createFileAtPath:appOpenLogPath contents:nil attributes:nil];
	}
	
	[pool release];
}
@end
