//
//  MSProtocolMediation.h
//  SimpleAds
//
//  Created by Guillermo Fernandez on 29/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdManager.h" 

#ifndef MS_TEST
#define MS_HOSTNAME	@"ads.mediasmart.es"
#else
#define MS_HOSTNAME	@"testads.mediasmart.es"
#endif

BOOL isConnected(void);

@interface MPAdManager (MediaSmart)


@property (nonatomic, copy) NSURL *clickURL;
- (NSURL*) clickURL;
- (NSURL*) interceptURL;
- (NSURL*) failURL;
- (NSURL*) impTrackerURL;
- (NSURL*) URL;
- (BOOL) isUsingWifi;
- (NSString*) carrierName;
- (NSString*) operatorIsoCode;
- (NSString*) operatorMCCMNC;
- (NSURL*) addNetworkingKeywordsTo:(NSURL*) input;

- (NSURL*) urlByMediation:(NSURL*)input;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d;
@end
