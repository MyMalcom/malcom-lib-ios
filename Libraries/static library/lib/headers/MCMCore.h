

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

#define MCMVersionSDK @"2.0.7"


//General imports
#import "MCMCoreManager.h"
#import "MCMModuleAdapter.h"
#import "MCMLog.h"
#import "MCMCoreUtils.h"


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
__VA_ARGS__;\
};
#else
#define IF_IOS6_OR_GREATER(...)
#endif

//IOS 7 check
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
#define IF_IOS7_OR_GREATER(...) \
if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) \
{ \
__VA_ARGS__;\
};
#else
#define IF_IOS7_OR_GREATER(...)
#endif
