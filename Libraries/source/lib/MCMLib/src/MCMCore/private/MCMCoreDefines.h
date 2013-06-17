/*
 *  MCMDefines.h
 */

//Config file
#define kMCMCoreInfoPlistName @"MCMCore-Info.plist"
#define kMCMCoreInfoPlistNameDevelopment @"MCMCore-Info-Development.plist"

// Only print Log in debug Mode (note: activate -DDEBUG in "other C flags")
#ifndef DLog
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define MCMLog(s, ...) NSLog(@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__]);
#else
#   define DLog(...);
#   define ALog(...);
#   define MCMLog(...);
#endif
#endif

#define KMCMLogActivated @"MCMLogActivated"

//Imports
#import "MCMCoreSingleton.h"
#import "MCMCoreWebAlertView.h"
#import "MCMCoreUtils.h"
#import "MCMCoreAPIRequest.h"