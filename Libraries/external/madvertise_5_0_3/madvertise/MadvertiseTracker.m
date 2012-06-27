//
//  MadTracker.m
//  MadvertiseTracking
//
//  Created by Moritz Becker on 11/1/10.
//  Copyright 2010 Madvertise. All rights reserved.
//

#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>
#import <netinet/in.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "MadvertiseUtilities.h"
#import "MadvertiseTracker.h"


// static variables
static BOOL madvertiseTrackerDebugMode = YES;
static BOOL trackerAlreadyEnabled = NO;

static NSString *productToken = @"test";
static NSString *madServer = @"http://ad.madvertise.de/action/";
//static NSString *madServer = @"http://127.0.0.1:9292/action/";

@implementation MadvertiseTracker

+ (void) enable {
    if (trackerAlreadyEnabled) {
        return;
    }
    
    trackerAlreadyEnabled = YES;
  
    [MadvertiseTracker reportActionToMadvertise:@"launch"];
  
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                    object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
                                                        [MadvertiseTracker reportActionToMadvertise:@"active"];
                                                    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                    object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
                                                        [MadvertiseTracker reportActionToMadvertise:@"inactive"];
                                                    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification
                                                    object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
                                                        [MadvertiseTracker reportActionToMadvertise:@"stop"];
                                                    }];
}

+ (void) reportActionToMadvertise:(NSString*) action_type {    
	NSMutableDictionary *context = [NSMutableDictionary dictionaryWithObjectsAndKeys:
							 UserAgentString(),                                 MADVERTISE_USER_AGENT_KEY,
							 action_type,                                       MADVERTISE_ACTION_TYPE_KEY,
                             [MadvertiseUtilities getIP],                       MADVERTISE_IP_KEY,
                             [MadvertiseUtilities getMacMD5Hash],               MADVERTISE_MACMD5_KEY,
                             [MadvertiseUtilities getMacSHA1Hash],              MADVERTISE_MACSHA1_KEY,
                             [MadvertiseUtilities getTimestamp],                MADVERTISE_TIMESTAMP_KEY,
                             [MadvertiseUtilities getAppName],                  MADVERTISE_APP_NAME_KEY,
                             [MadvertiseUtilities getAppVersion],               MADVERTISE_APP_VERSION_KEY,
                             (madvertiseTrackerDebugMode ? @"true" : @"false"), MADVERTISE_DEBUG_KEY,
                             nil];
    
    [MadvertiseTracker performSelectorInBackground:@selector(report:) withObject:context];
}

+ (void) setDebugMode: (BOOL) debug {
	madvertiseTrackerDebugMode = debug;
}

+ (void) setProductToken: (NSString *) token {
	productToken = token;
}

+ (void) report: (NSMutableDictionary*) context {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    MadLog(@"%@", documentsDirectory);
    NSString *appOpenPath = [documentsDirectory stringByAppendingPathComponent:@"mad_launch_tracking"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
    bool firstLaunch = ![fileManager fileExistsAtPath:appOpenPath];
    [context setValue:(firstLaunch ? @"1" : @"0") forKey:MADVERTISE_FIRST_LAUNCH_KEY];
    
    MadLog(@"Sending tracking request to madvertise. token=%@",productToken);
	
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", madServer , productToken]];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
	NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];  
	[headers setValue:@"application/x-www-form-urlencoded; charset=utf-8" forKey:@"Content-Type"];
	
    NSString *body = @"";	
	unsigned int n = 0;
	for(NSString *key in context) {
		body = [body stringByAppendingString:[NSString stringWithFormat:@"%@=%@", key, [context objectForKey:key]]];
		if(++n != [context count]) {
            body = [body stringByAppendingString:@"&"];
        }
	}
	
    [request setHTTPMethod:@"POST"];  
	[request setAllHTTPHeaderFields:headers]; 
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSURLResponse *response = nil;
	NSError *error  = nil;
	
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if( (!error) && ([(NSHTTPURLResponse *)response statusCode] == 200)) {
		[fileManager createFileAtPath:appOpenPath contents:nil attributes:nil];
	}

#ifdef DEBUG
	NSString* debugMessage = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
    MadLog(@"Response from madvertise %@", debugMessage);
    [debugMessage release];
#endif 
  
    [headers release];
    [pool release];
}

@end