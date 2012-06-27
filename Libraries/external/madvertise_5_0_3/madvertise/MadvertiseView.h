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

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <netinet/in.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAMediaTimingFunction.h>

#import "MadvertiseUtilities.h"
#import "MadvertiseAd.h"
#import "MadvertiseTracker.h"
#import "MadvertiseDelegationProtocol.h"
#import "JSONKit.h"
#import "NSString+URLEncoding.h"
#import "MRAdView.h"
#import "MPAdBrowserController.h"

// enum of available banner formats
typedef enum tagMadvertiseAdClass {
  MadvertiseAdClassMMA,
  MadvertiseAdClassMediumRectangle,
  MadvertiseAdClassLeaderboard,
  MadvertiseAdClassFullscreen,
  MadvertiseAdClassPortrait,
  MadvertiseAdClassLandscape,
  MadvertiseAdClassRichMedia,
  MadvertiseAdClassIphonePreloader,
  MadvertiseAdClassIpadPreloader
} MadvertiseAdClass;

@class InAppLandingPageController;
@class MadvertiseAd;

@interface MadvertiseView : UIView<UIWebViewDelegate, MPAdBrowserControllerDelegate, MRAdViewDelegate> {
  
    // attributes
    id<MadvertiseDelegationProtocol> madDelegate;           // the delegate which receives ad related events like: adLoaded or adLoadFailed
    NSMutableData* receivedData;                            // data received thorugh the connection to the ad server
    NSMutableURLRequest* request;  
    NSURLConnection *conn;                                  // current request object
  
    MadvertiseAd* currentAd;                                // current ad
    MadvertiseAdClass currentAdClass;                       // ad type
    MRAdViewPlacementType placementType;
  
    NSInteger responseCode;                                 // flag that indicates if http response from ad server is ok
    bool isExpanded;                                        // flag that indicates if there is an expanded ad action
  
    UIView* currentView;                                 // one of the two views above, depending on user action
    MRAdView *mraidView;
  
    NSLock* lock;                                           // lock which is used to avoid race conditions while requesting an ad

    NSTimer* timer;                                         // the ad rotation timer
    double interval;                                        // interval of ad refresh
    int x, y;                                               // Position
  
    double animationDuration;
}


/////////////////
/// constructor
////////////////

@property (nonatomic, assign) id<MadvertiseDelegationProtocol> madDelegate;
@property (nonatomic, retain) MadvertiseAd *currentAd;
@property (nonatomic, retain) NSMutableURLRequest *request;
@property (nonatomic, retain) UIView *currentView;
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, retain) NSURLConnection *conn;
@property (nonatomic, retain) NSMutableData* receivedData;


- (CGSize) getParentViewDimensions;
- (MadvertiseView*)initWithDelegate:(id<MadvertiseDelegationProtocol>)delegate withClass:(MadvertiseAdClass)adClassValue placementType:(MRAdViewPlacementType) type secondsToRefresh:(int)secondsToRefresh;
- (void) createAdReloadTimer;
- (void) displayView;
- (void) stopTimer;
- (void)swapView:(UIView*)newView oldView:(UIView*) oldView;
- (void)loadAd;
- (void)openInAppBrowserWithUrl:(NSString*)url;

+ (MadvertiseView*)loadAdWithDelegate:(id<MadvertiseDelegationProtocol>)delegate withClass:(MadvertiseAdClass)adClassValue placementType:(MRAdViewPlacementType) type secondsToRefresh:(int)secondsToRefresh;
+ (MadvertiseView*)loadAdWithDelegate:(id<MadvertiseDelegationProtocol>)delegate withClass:(MadvertiseAdClass)adClassValue secondsToRefresh:(int)secondsToRefresh;
+ (MadvertiseView*)loadRichMediaAdWithDelegate:(id<MadvertiseDelegationProtocol>)delegate;
+ (void) handlerWithObserver:(id) observer AndSelector:(SEL) selector ForEvent:(NSString*) event;
- (void)place_at_x:(int)x_pos y:(int)y_pos;               // position the frame for the view
- (UIViewController *)viewControllerForPresentingModalView;
- (void)dismissBrowserController:(MPAdBrowserController *)browserController;
- (void)dismissBrowserController:(MPAdBrowserController *)browserController animated:(BOOL)animated;

@end
