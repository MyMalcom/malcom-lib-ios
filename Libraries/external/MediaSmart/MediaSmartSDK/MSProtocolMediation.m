//
//  MSProtocolMediation.m
//  SimpleAds
//
//  Created by Guillermo Fernandez on 29/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MSProtocolMediation.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "Reachability.h"


@implementation MPAdManager (MediaSmart) 

	- (NSURL*) urlByMediation:(NSURL*)input
	{
		NSString * url= [input  absoluteString];
		NSRange search =[url rangeOfString:@"/m/"];
		
		if (search.length>0) {
			NSString * localUrl = [url substringFromIndex:search.location];
			NSURL* result= [NSURL URLWithString: [
			 [NSString stringWithFormat:@"http://%@%@",MS_HOSTNAME,localUrl] 
			 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
			];
			return result;
		}
		return input;
	}
@dynamic clickURL;
	- (NSURL*) clickURL
	{
		return [self urlByMediation: _clickURL];
	}
	- (NSURL*) interceptURL
	{
		return [self urlByMediation: _interceptURL];
	}
	- (NSURL*) failURL
	{
		return [self urlByMediation: _failURL];
	}
	- (NSURL*) impTrackerURL
	{
		return [self urlByMediation: _impTrackerURL];
	}
	- (NSURL*) URL
	{
		return [self addNetworkingKeywordsTo:[self urlByMediation: _URL]];
	}
	- (NSURL*) addNetworkingKeywordsTo:(NSURL*) input
	{
		if (input==nil) return input;
		
		NSString * url= [input  absoluteString];
		NSString * wifiKeyword = [self isUsingWifi]?@"p:net:wifi,":@"p:net:3g,";
		NSString * operator = [[self carrierName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString * country =[[self operatorIsoCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString * operatorCode =[[self operatorMCCMNC] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		NSString * result = url;
		NSRange search =[url rangeOfString:@"&q="];
		if (search.location!= NSNotFound) {
			NSString * after = [url substringFromIndex:search.location+3];
			NSString * before = [url substringToIndex:search.location+3];
			result = [NSString stringWithFormat:@"%@%@%@",before,wifiKeyword,after];
		} else {
			result =[NSString stringWithFormat:@"%@&q=%@",result,wifiKeyword ];

		}
		if (operator != nil && operator.length>0) {
			result =[NSString stringWithFormat:@"%@&ms_cn=%@",result,operator ];
		}
		if (country != nil && country.length>0) {
			result =[NSString stringWithFormat:@"%@&ms_country=%@",result,country ];
		}
		if (operatorCode != nil && operatorCode.length>0) {
			result =[NSString stringWithFormat:@"%@&ms_cnc=%@",result,operatorCode ];
		}
		return  [NSURL URLWithString:result];
	}

	-(BOOL) isUsingWifi
	{
		Reachability *reachability = [Reachability reachabilityForInternetConnection];
		[reachability startNotifier];
		
		NetworkStatus status = [reachability currentReachabilityStatus];
		
		if (status == ReachableViaWiFi)
		{
			//WiFi
			return YES;
		}
		return NO;
	}

	- (NSString*) carrierName
	{
		CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
		CTCarrier *carrier = [netinfo subscriberCellularProvider];
		NSString * result= [carrier carrierName];
		[netinfo release];
		return result;
	}
	- (NSString*) operatorIsoCode
	{
		CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
		CTCarrier *carrier = [netinfo subscriberCellularProvider];
		NSString * result= [carrier isoCountryCode];
		[netinfo release];
		return result;
	}

	- (NSString*) operatorMCCMNC
	{
		CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
		CTCarrier *carrier = [netinfo subscriberCellularProvider];
		NSString * result= [NSString stringWithFormat:@"%@%@",[carrier mobileCountryCode],[carrier mobileNetworkCode]];
		[netinfo release];
		return result;
	}


	- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
	{
		NSString *content = [[[NSString alloc]  initWithBytes:[d bytes]
							length:[d length] encoding: NSUTF8StringEncoding] autorelease];
		NSString * find = [NSString stringWithFormat:@"http://%@",HOSTNAME];
		NSString * replace = [NSString stringWithFormat:@"http://%@",MS_HOSTNAME];
		NSString *transform=[content stringByReplacingOccurrencesOfString:find withString:replace];
		
		// Force mediation
		self.clickURL=[self clickURL];
		[_data appendData:[transform dataUsingEncoding:NSUTF8StringEncoding] ];
	}

	


@end


BOOL isConnected(void)
{
	Reachability *reachability = [Reachability reachabilityForInternetConnection];
	[reachability startNotifier];
	
	NetworkStatus status = [reachability currentReachabilityStatus];
	return status != NotReachable;
}
