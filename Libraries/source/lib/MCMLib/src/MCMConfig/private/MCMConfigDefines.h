/*
 *  MCMDefines.h
 */

#import "MCMCoreDefines.h"

#define kMalcomSettingsRemoteName @"config"
#define kMalcomSettingsLocalName @"MCMConfig-Info.plist"
#define kMalcomSectionsLocalName @"MCMSections.opml"

//Timeout must be small as we want a fast load witout matter if it fails often
#define kMalcomSettingsTimeout 8

#define kSplashCodeUserDefaults @"MCMConfigSplashCode"
#define kInfoMessageUserDefaults @"MCMConfigInfoMessage"
#define kWebIntersitialUserDefaults @"MCMWebIntersitial"
#define kInfoRepetitionsUserDefaults @"MCMConfigInfoRepetitions"


#define kSplashZIndex 1