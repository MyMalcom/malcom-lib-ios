

#define kMCMCoreKeyMalcomAppId @"MalcomAppId"
#define kMCMCoreKeyAssetsAppSecretKey @"MalcomAppSecretKey"
#define kMCMCoreKeyMalcomBaseUrl @"MalcomBaseURL"
#define kMCMCoreKeyAssetsBaseUrl @"AssetsBaseURL"

#define MCMCloseIntersitialNotification @"MCMCloseIntersitialNotification"

//#define kMCMBaseUrl @"http://malcom-api-dev.elasticbeanstalk.com/"
//#define kMCMBaseUrl @"http://malcom-api-pre.elasticbeanstalk.com/"
#define kMCMBaseUrl @"https://api.mymalcom.com/"

#define kMCMAdwhirlURL @"https://ads.mymalcom.com/"

#define MCMReceiveAd @"mcmReceiveAd"
#define MCMFailReceiveAd @"mcmFailReceiveAd"
#define MCMNotificationAdsAreOff @"mcmNotificationAdsAreOff"

#define MCMVersionSDK @"2.0.2"


//General imports
#import "MCMCoreManager.h"
#import "MCMModuleAdapter.h"
#import "MCMViewController.h"
#import "MCMApplicationDelegate.h"
#import "MCMLog.h"
#import "MCMCoreUtils.h"
#import "MCMCampaignsManager.h"


//Malcom log (Only show logs on DEBUG mode)
#ifdef DEBUG
#   define MCMLog(s, ...) NSLog(@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__]);
#else
#   define MCMLog(...);
#endif

//IOS 6 check
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
#define IF_IOS6_OR_GREATER(...) \
if([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) \
{ \
NSLog(@"IOS kCFCoreFoundationVersionNumber %.f",kCFCoreFoundationVersionNumber);\
__VA_ARGS__;\
};
#else
#define IF_IOS6_OR_GREATER(...)
#endif
