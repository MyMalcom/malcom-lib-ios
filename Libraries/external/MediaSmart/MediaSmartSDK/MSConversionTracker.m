//
//  MSConversionTracker.m
//  SimpleAds
//
//  Created by Guillermo Fernandez on 12/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MSConversionTracker.h"
#import "MPConstants.h"
#import "MPGlobal.h"
#import "MPLogging.h"
#import "MSProtocolMediation.h"

#define kUserAgentContextKey @"user-agent"
#define kEventContextKey @"event-id"
#define kNumberContextKey @"event-number"
#define kSchemeContextKey @"browser-scheme"

@interface MSConversionTracker (Internal)
- (void)reportConversionSynchronous:(NSDictionary *)context;

@end



@implementation MSConversionTracker




+ (MSConversionTracker *)sharedConversionTracker
{
	static MSConversionTracker *sharedConversionTracker;
	
	@synchronized(self)
	{
		if (!sharedConversionTracker)
			sharedConversionTracker = [[MSConversionTracker alloc] init];
		return sharedConversionTracker;
	}
}

- (void)reportConversionWith:(NSString*)optionalScheme ForEvent:(NSString *)event Number:(uint) number
{
	// MPUserAgentString() must be called on the main thread, since it manipulates a UIWebView.
	NSString *userAgent = MPUserAgentString();
	if (number <=0 || number>5) {
		number=1;
	}
	if (!isConnected() ||event==nil || event.length ==0) {
		return;
	}
	NSString * scheme = (optionalScheme==nil)?@"":optionalScheme;
	
	
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 userAgent, kUserAgentContextKey,
							 event, kEventContextKey,
							 scheme,kSchemeContextKey,
							 [NSNumber numberWithInt:number],kNumberContextKey,nil];
	
	if (flashPerformed()||optionalScheme==nil) {
		// UDID and mobile cookie already bound. No browser flash required
		[self performSelectorInBackground:@selector(reportConversionSynchronous:) 
							   withObject:context];
	} else {
		performFlash(context);
	}
}



#pragma mark -
#pragma mark Internal



- (void)reportConversionSynchronous:(NSDictionary *)context
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *event = [context objectForKey:kEventContextKey];
	NSNumber *number = [context objectForKey:kNumberContextKey];
	NSString *userAgent = [context objectForKey:kUserAgentContextKey];
	NSString * identifier=[NSString stringWithFormat:@"mediaSmartEvent_%d_%@.log",[event hash],number];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] <= 0) return;
	
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *appOpenLogPath = [documentsDir stringByAppendingPathComponent:identifier];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// The existence of  the log file tells us whether we have already reported this event.
	if ([fileManager fileExistsAtPath:appOpenLogPath]) return;
	
	
	
	NSString *appOpenUrlString = [NSString stringWithFormat:@"http://%@/m/open?v=8&udid=%@&id=%@&ms_event_num=%@",
								  MS_HOSTNAME,
								  MPHashedUDID(),
								  event,
								  number];
	
	MPLogInfo(@"Reporting application did launch for the first time to MediaSmart: %@", appOpenUrlString);
	
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

BOOL flashPerformed(void)
{
	NSString * identifier=[NSString stringWithFormat:@"mediaSmartFlash_%@.log",MPHashedUDID()];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] <= 0) return NO;
	
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *appOpenLogPath = [documentsDir stringByAppendingPathComponent:identifier];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if ([fileManager fileExistsAtPath:appOpenLogPath]) {
		MPLogInfo(@"flash already performed");
		return YES; // flash was already performed
	}
	return NO;
}

BOOL performFlash(NSDictionary* context)
{
	NSString *event = [context objectForKey:kEventContextKey];
	NSNumber *number = [context objectForKey:kNumberContextKey];
	NSString *scheme = [context objectForKey:kSchemeContextKey];
	
	NSString *url = [NSString stringWithFormat:@"http://%@/event/flash?v=8&udid=%@&id=%@&ms_event_num=%@&ms_scheme=%@",
								  MS_HOSTNAME,
								  MPHashedUDID(),
								  event,
								  number,
								  scheme
								 ];
	MPLogInfo(@"Opening mobile safari for %@", url);
	// Save flag as performed
	NSString * identifier=[NSString stringWithFormat:@"mediaSmartFlash_%@.log",MPHashedUDID()];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString * reportLog=nil;
	if ([paths count]>0 ) {
		NSString *documentsDir = [paths objectAtIndex:0];
		reportLog= [documentsDir stringByAppendingPathComponent:identifier];
		[fileManager createFileAtPath:reportLog contents:nil attributes:nil];
	}
	
	BOOL result=[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	
	if (!result) {
		MPLogInfo(@"Unable to open mobile safari for %@", url);
		// Remove flash flag
		NSError *dummy;
		[fileManager removeItemAtPath:reportLog error:&dummy];

	} 
	return result;
		
}
