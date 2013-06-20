

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 Utilities class used to retrieve system and device information
 @since 1.0
 */
@interface MCMCoreUtils : NSObject {
    
}


/**
 Returns an alphanumeric string unique to each device based on various hardware details
 @return string with device unique identifier (example: 4e969024c07e24b83e1650404ccf0bb227a051b4)
 */
+ (NSString *)uniqueIdentifier DEPRECATED_ATTRIBUTE;

/**
 Returns an alphanumeric string unique to each device suported by IOS7
 @return string with device unique identifier (example: 4e969024c07e24b83e1650404ccf0bb227a051b4)
 */
+ (NSString *)deviceIdentifier;

/** 
 Returns the name of the operating system running on the device represented by the receiver
 @return string with the name of the operating system (example: iPhone OS)
 */
+ (NSString *)systemName;

/** 
 Returns the current version of the operating system
 @return string with the current version of the operating system (example: 4.2.1)
 */
+ (NSString *)systemVersion; 

/** 
 Returns the model of the device
 @return string with the model of the device (example: iPhone)
 */
+ (NSString *)deviceModel;

/** 
 Returns the name identifying the device given by the user
 @return string with the name identifying the device given by the user (example: MyDeviceName)
 */
+ (NSString *)deviceName;

/**
 Returns machine class
 @return string with the machine class (example: iPhone1,2)
 */
+ (NSString *)machinePlatform;

/**
 Returns machine platform decoded name
 @return string with the machine type in human redeable format (example: iPhone 3GS)
 */
+ (NSString *)machinePlatformName;

/**
 Returns machine model
 @return string with the machine model (example: N82AP)
 */
+ (NSString *)machineModel;

/** 
 Returns the user selected language on the user's preferences
 Based on ISO 639-1 alfa-2
 @return string with user selected language on the device (example: en)
 */
+ (NSString *)currentLanguage;

/** 
 Returns the device language identifier
 @return string with the device language identifier (example: es_ES)
 */
+ (NSString *)languageDeviceIdentifier;

/** 
 Returns the device language identifier text
 @return string with the device language identifier text (example: Spanish (Spain))
 */
+ (NSString *)languageDeviceIdentifierText;

/** 
 Returns the device language code based on device's region
 @return string with the device language code (example: es)
 */
+ (NSString *)languageDeviceLanguageCode;

/** 
 Returns the device country code from the language identifier
 Based on ISO 3166-1 alfa-2 http://www.iso.org/iso/english_country_names_and_code_elements
 @return string with the device country code (example: ES)
 */
+ (NSString *)languageDeviceCountryCode;

/**
 Returns the application version
 @return string with the version of the application (example: 0)
 */
+ (NSString *)applicationVersion;

/**
 Returns the users timezone
 @return string with the timezone
 */
+ (NSString *)userTimezone;

/**
 Returns the user carrier if exists
 @return string with the carrier name
 @since 1.0.3
 */
+ (NSString *) carrierName;

/**
 Returns the platform
 @return string with the platform name
 @since 2.0.0
 */

+ (NSString *) platform;


/**
 Returns the current rectFor current screen.
 @return CGRect with the bounds of the screen counting with the orientation.
 @since 2.0.0
 */
+ (CGRect) rectForViewScreen;

@end
