/*
 *  MVCConfig.h
 */

/**
 Notification sent when the MCMConfigManager ends updating it's data from the server
 */
#define MCMConfigUpdateNotification @"MCMConfigUpdateNotification"

/**
 Notification sent when the MCMConfigSectionManager ends updating it's data from the server
 */
#define MCMConfigSectionsUpdateNotification @"MCMConfigSectionsUpdateNotification"

/**
Predefined Malcom Keys
 */
typedef NSString* MCMConfigKey;
//General keys
#define MCMConfigKeyAppStoreVersion @"appStoreVersion"
#define MCMConfigKeyUrlAppStore @"urlAppStore"
#define MCMConfigKeyUriServerBase @"uriServerBase"
#define MCMConfigKeyTitle @"title"
#define MCMConfigKeyUrlOPMLSections @"opmlURL"

//Splash
#define MCMConfigKeySplashImageUrl @"splashImageUrl"
#define MCMConfigKeySplashImageName @"splashImageName"
//Alert type
#define MCMAlertType @"alertType"
//Version condition
#define MCMVersionCondition @"versionCondition"
#define MCMIntersitialVersionCondition @"interstitialVersionCondition"
//Intersitial Version condition
#define MCMInterstitialVersion @"interstitialVersion"
//Intersitial Web
#define MCMInterstitialWeb @"interstitialWeb"
#define MCMShowInterstitial @"showInterstitial"
//Idioma por defecto
#define MCMDefaultLanguage @"defaultLanguage"
//#define MCMConfigKeySplashDelay @"splashDelay"
#define MCMConfigKeySplashDelay @"animationDelay"
//App Problems keys
#define MCMConfigKeyAppProblems @"appProblems"
#define MCMConfigKeyAppProblemsMsg @"appProblemsMsg"
#define MCMConfigKeyAppProblemsVersion @"appProblemsVersion"
//Force update keys
#define MCMConfigKeyForceUpdate @"forceUpdate"
#define MCMConfigKeyForceUpdateMsg @"forceUpdateMsg"
#define MCMConfigKeyForceUpdateVersion @"forceUpdateVersion"
//Suggestion keys
#define MCMConfigKeySuggestUpdate @"suggestUpdate"
#define MCMConfigKeySuggestUpdateMsg @"suggestUpdateMsg"
#define MCMConfigKeySuggestUpdateVersion @"suggestUpdateVersion"
//Information keys
#define MCMConfigKeyShowInfo @"showInfoMsg"
#define MCMConfigKeyShowInfoMsg @"infoMsg"
#define MCMConfigKeyShowInfoVersion @"infoMsgVersion"
#define MCMConfigKeyShowInfoType @"infoMsgType"
#define MCMConfigKeyShowInfoRepetitions @"infoMsgTimesToShow"

#define MCMInterstitialTimesToShow @"interstitialTimesToShow"


//Global imports
#import "MCMConfigManager.h"
#import "MCMConfigSectionManager.h"
#import "MCMConfigApplicationDelegate.h"

//widgets
#import "MCMConfigSplashViewController.h"

//categories
#import "UITabBarController+MCMConfig.h"
 