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

#import <CoreLocation/CoreLocation.h>

typedef enum tagMadvertiseAnimationClass {
  MadvertiseAnimationClassLeftToRight,
  MadvertiseAnimationClassTopToBottom,
  MadvertiseAnimationClassCurlDown,
  MadvertiseAnimationClassFade,
  MadvertiseAnimationClassNone 
} MadvertiseAnimationClass;

@class MadvertiseView;

@protocol MadvertiseDelegationProtocol<NSObject>

// The appId is your token which associates this application with your site in the
// madvertise plattform. Log in under http://www.madvertise.de to get your appId.
@required
- (NSString *) appId;


@optional

- (double) durationOfBannerAnimation;               // 1.5 for example
- (MadvertiseAnimationClass) bannerAnimationTyp;    // curlDown, topToBottom, leftToRight, fade, none
- (void) inAppBrowserWillOpen;                      // YES | NO
- (void) inAppBrowserClosed;                        // YES | NO
- (BOOL) debugEnabled;                              // YES | NO
- (BOOL) mRaidDisabled;                             // YES | NO
- (BOOL) downloadTrackerEnabled;                    // YES | NO
- (NSString *) adServer;                            // default server is ad.madvertise.de.
- (CLLocationCoordinate2D) location;
- (NSString *) gender;                              // F | M 
- (NSString *) age;                                 // single number 1,2,.. || range 0-120
@end
