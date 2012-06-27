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

#import <Foundation/Foundation.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>
#import <netinet/in.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIDevice.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#if DEBUG
#define MadLog(format, ...) [MadvertiseUtilities logWithPath:__FILE__ line:__LINE__ string:(format), ## __VA_ARGS__]
#else
#define MadLog(format, ...)
#endif

#define MADVERTISE_SDK_VERION @"5.0.3"

#define MADVERTISE_USER_AGENT_KEY @"ua"
#define MADVERTISE_APP_KEY @"app"
#define MADVERTISE_MACSHA1_KEY @"mac_sha1"
#define MADVERTISE_MACMD5_KEY @"mac_md5"
#define MADVERTISE_TOKENSHA1_KEY @"token_sha1"
#define MADVERTISE_TOKENMD5_KEY @"token_md5"
#define MADVERTISE_IP_KEY @"ip"
#define MADVERTISE_FORMAT_KEY @"format"
#define MADVERTISE_REQUESTER_KEY @"requester"
#define MADVERTISE_TIMESTAMP_KEY @"ts"
#define MADVERTISE_BANNER_TYPE_KEY @"banner_type"
#define MADVERTISE_ACTION_TYPE_KEY @"at"
#define MADVERTISE_APP_NAME_KEY @"app_name"
#define MADVERTISE_APP_VERSION_KEY @"app_version"
#define MADVERTISE_FIRST_LAUNCH_KEY @"first_launch"
#define MADVERTISE_DEBUG_KEY @"debug"
#define MADVERTISE_SDK_VERION_KEY @"version"
#define MADVERTISE_AGE_KEY @"age"
#define MADVERTISE_GENDER_KEY @"gender"
#define MADVERTISE_LNG_KEY @"lng"
#define MADVERTISE_LAT_KEY @"lat"
#define MADVERTISE_ORIENTATION_KEY @"orientation"
#define MADVERTISE_DEVICE_WIDTH_KEY @"device_width"
#define MADVERTISE_DEVICE_HEIGHT_KEY @"device_height"
#define MADVERTISE_PARENT_HEIGHT_KEY @"parent_height"
#define MADVERTISE_PARENT_WIDTH_KEY @"parent_width"
#define MADVERTISE_MRAID_KEY @"mraid"


NSString *UserAgentString(void);

@interface MadvertiseUtilities : NSObject
+ (NSString*) getIP;
+ (NSString*) getMacMD5Hash;
+ (NSString*) getMacSHA1Hash;
+ (NSString*) getTimestamp;
+ (NSString*) getAppName;
+ (NSString*) getAppVersion;
+ (CGSize) getScreenResolution;
+ (NSString*) getDeviceOrientation;

+ (void)logWithPath:(char *)path line:(NSUInteger)line string:(NSString *)format, ...;

@end
