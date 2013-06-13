

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

#define MCMVersionSDK @"2.0.1"


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
