// Copyright 2011 madvertise Mobile Advertising GmbH
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/NSData.h>
#import "MadvertiseUtilities.h"

NSString* UserAgentString() {
	static NSString *userAgent = nil;
    
    if (!userAgent) {
        UIWebView *webview = [[UIWebView alloc] init];
        userAgent = [[webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] copy];  
        [webview release];
    }
    return userAgent;
}

@implementation MadvertiseUtilities


+ (NSString *) getIP {
	NSString *result = nil;
	
	struct ifaddrs*	addrs;
	BOOL success = (getifaddrs(&addrs) == 0);
	if (success)
	{
		const struct ifaddrs* cursor = addrs;
		while (cursor != NULL)
		{
			NSMutableString* ip;
			NSString* interface = nil;
			if (cursor->ifa_addr->sa_family == AF_INET)
			{
				const struct sockaddr_in* dlAddr = (const struct sockaddr_in*) cursor->ifa_addr;
				const uint8_t* base = (const uint8_t*)&dlAddr->sin_addr;
				ip = [NSMutableString new];
				for (int i = 0; i < 4; i++)
				{
					if (i != 0)
						[ip appendFormat:@"."];
					[ip appendFormat:@"%d", base[i]];
				}
				interface = [NSString stringWithFormat:@"%s", cursor->ifa_name];
				if([interface isEqualToString:@"en0"] && result == nil) {
					result = [ip copy];
				}
				if(![interface isEqualToString:@"lo0"] && ![interface isEqualToString:@"en0"] && ![interface isEqualToString:@"fw0"] && ![interface isEqualToString:@"en1"] ) {
					// NSLog(@"Interface %@", interface);
					result = [ip copy];
				}
        [ip release];
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
    
	if (result == nil) {
        result = @"127.0.0.1";
    }
    
	return [result autorelease];
}

+ (NSString*) sha1:(NSString*)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
         [output appendFormat:@"%02x", digest[i]];
    }
    
    return  output;
}

+ (NSString *) getMacAddress {
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    NSString            *errorFlag = NULL;
    size_t              length;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;              
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0) {
        errorFlag = @"if_nametoindex failure";
    }
    // Get the size of the data available (store in len)
    else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) {
        errorFlag = @"sysctl mgmtInfoBase failure";
    }
    // Alloc memory based on above call
    else if ((msgBuffer = malloc(length)) == NULL) {
        errorFlag = @"buffer allocation failure";
    }
    // Get system information, store in buffer
    else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0) {
        free(msgBuffer);
        errorFlag = @"sysctl msgBuffer failure";
    }
    else {
        // Map msgbuffer to interface message structure
        struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        unsigned char macAddress[6];
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
        
        // Release the buffer memory
        free(msgBuffer);
        
        return macAddressString;
    }
    
    return errorFlag;
}

+ (NSString*) getMacMD5Hash {
    return [MadvertiseUtilities md5:[MadvertiseUtilities getMacAddress]];
}

+ (NSString*) getMacSHA1Hash {
    return [MadvertiseUtilities sha1:[MadvertiseUtilities getMacAddress]];
}

+ (NSString*) getTimestamp {
  return [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
}

+ (NSString*) getAppName {
  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

+ (NSString*) getAppVersion {
  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (void)logWithPath:(char *)path line:(NSUInteger)line string:(NSString *)format, ... {
	NSString *pathString = [[NSString alloc] initWithBytes:path	length:strlen(path) encoding:NSUTF8StringEncoding];
	
	va_list argList;
	va_start(argList, format);
	NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:argList];
	va_end(argList);
	
	NSLog(@"%@", [NSString stringWithFormat:@"%@ (%d): %@", [pathString lastPathComponent], line, formattedString]);
	[formattedString release];
	[pathString release];
}

+ (CGSize) getScreenResolution {
    CGRect screen = [[UIScreen mainScreen] bounds];
    return CGSizeMake(screen.size.width, screen.size.height);
}

+ (NSString*) getDeviceOrientation {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(orientation)) {
        return @"landscape";
    } else {
        return @"portrait";
    }
}

@end
