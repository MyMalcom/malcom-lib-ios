//
//  MCMCoreUtils.m
//

#import "MCMCoreUtils.h"
#import <UIKit/UIKit.h>
#import <sys/sysctl.h>

#if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#endif

#import "MCMODIN.h"
#import <AdSupport/AdSupport.h>

@implementation MCMCoreUtils

+ (NSString *)uniqueIdentifier {
    
    return MCMODIN1();
}

+ (NSString *)deviceIdentifier {
    
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

+ (NSString *)systemName
{
	return [[UIDevice currentDevice] systemName];
}

+ (NSString *)systemVersion
{
	return [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]];
}

+ (NSString *)deviceModel
{
    return [[UIDevice currentDevice] model];
}

+ (NSString *)deviceName
{
    return [[UIDevice currentDevice] name];
}

/**
 Returns machine class
 @return string with the machine class (example: iPhone1,2)
 iFPGA ->		¿?
 
 iPhone1,1 ->	iPhone 1G
 iPhone1,2 ->	iPhone 3G
 iPhone2,1 ->	iPhone 3GS
 iPhone3,1 ->	iPhone 4/AT&T
 iPhone3,2 ->	iPhone 4/Other Carrier?
 iPhone3,3 ->	iPhone 4/Other Carrier?
 iPhone4,1 ->	iPhone 5 ¿?
 
 iPod1,1   -> iPod touch 1G 
 iPod2,1   -> iPod touch 2G 
 iPod2,2   -> iPod touch 2.5G ¿?
 iPod3,1   -> iPod touch 3G
 iPod4,1   -> iPod touch 4G
 iPod5,1   -> iPod touch 5G ¿?
 
 iPad1,1   -> iPad 1G, WiFi
 iPad1,?   -> iPad 1G, 3G <- needs 3G owner to test
 iPad2,1   -> iPad 2G (iProd 2,1)
 (Note: there is yet no solution to differentiate iPad and iPad 3G)(
 
 AppleTV2,1 -> AppleTV 2
 
 i386, x86_64 -> iPhone Simulator, iPad Simulator
 Code from UIDeviceHardware (https://github.com/erica/uidevice-extension/)
 */
+ (NSString *)machinePlatform
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	free(machine);
	return platform;
}


+ (NSString *)machinePlatformName
{
	NSString *platform = [self machinePlatform];
    
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    
    //iPod
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad 1";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4";
    
    //Simulator
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    //AppleTV
    if ([platform isEqualToString:@"AppleTV2,1"]) return @"Apple TV 2";
	
    return platform;
}


+ (NSString *)machineModel
{
	size_t size;
	sysctlbyname("hw.model", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.model", machine, &size, NULL, 0);
	NSString *model = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	free(machine);
	return model;
}


+ (NSString *)currentLanguage
{
    NSString *langCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [[[[langCode stringByReplacingOccurrencesOfString:@"-" withString:@"_"] componentsSeparatedByString:@"_"] objectAtIndex:0] lowercaseString];
}

+ (NSString *)languageDeviceIdentifier
{
    return [[NSLocale currentLocale] localeIdentifier];
}

+ (NSString *)languageDeviceIdentifierText
{
    return [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:[[NSLocale currentLocale] localeIdentifier]];
}

+ (NSString *)languageDeviceLanguageCode
{
    return [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode];
}

/** 
 Returns the device country code from the language identifier
 Based on ISO 3166-1 alfa-2 http://www.iso.org/iso/english_country_names_and_code_elements
 AD Andorra
 AE United Arab Emirates
 AF Afghanistan
 AG Antigua and Barbuda
 AI Anguilla
 AL Albania
 AM Armenia
 AN Netherlands Antilles
 AO Angola
 AQ Antarctica
 AR Argentina
 AS American Samoa
 AT Austria
 AU Australia
 AW Aruba
 AX Åland Islands
 AZ Azerbaijan
 BA Bosnia and Herzegovina
 BB Barbados
 BD Bangladesh
 BE Belgium
 BF Burkina Faso
 BG Bulgaria
 BH Bahrain
 BI Burundi
 BJ Benin
 BL Saint Barthélemy
 BM Bermuda
 BN Brunei
 BO Bolivia
 BR Brazil
 BS Bahamas
 BT Bhutan
 BV Bouvet Island
 BW Botswana
 BY Belarus
 BZ Belize
 CA Canada
 CC Cocos [Keeling] Islands
 CD Congo - Kinshasa
 CF Central African Republic
 CG Congo - Brazzaville
 CH Switzerland
 CI Côte d’Ivoire
 CK Cook Islands
 CL Chile
 CM Cameroon
 CN China
 CO Colom bia
 CR Costa Rica
 CU Cuba
 CV Cape Verde
 CX Christmas Island
 CY Cyprus
 CZ Czech Republic
 DE Germany
 DJ Djibouti
 DK Denmark
 DM Dominica
 DO Dominican Republic
 DZ Algeria
 EC Ecuador
 EE Estonia
 EG Egypt
 EH Western Sahara
 ER Eritrea
 ES Spain
 ET Ethiopia
 FI Finland
 FJ Fiji
 FK Falkland Islands
 FM Micronesia
 FO Faroe Islands
 FR France
 GA Gabon
 GB United Kingdom
 GD Grenada
 GE Georgia
 GF French Guiana
 GG Guernsey
 GH Ghana
 GI Gibraltar
 GL Greenland 
 GM Gambia
 GN Guinea
 GP Guadeloupe
 GQ Equatorial Guinea
 GR Greece
 GS South Georgia and the South Sandwich Islands
 GT Guatemala
 GU Guam
 GW Guinea-Bissau
 GY Guyana
 HK Hong Kong SAR China
 HM Heard Island and McDonald Islands
 HN Honduras
 HR Croatia
 HT Haiti
 HU Hungary
 ID Indonesia
 IE Ireland
 IL Israel
 IM Isle of Man
 IN India
 IO British Indian Ocean Territory
 IQ Iraq
 IR Iran
 IS Iceland
 IT Italy
 JE Jersey
 JM Jamaica
 JO Jordan
 JP Japan
 KE Kenya
 KG Kyrgyzstan
 KH Cambodia
 KI Kiribati
 KM Comoros
 KN Saint Kitts and Nevis
 KP North Korea
 KR South Korea
 KW Kuwait
 KY Cayman Islands
 KZ Kazakhstan
 LA Laos
 LB Lebanon
 LC Saint Lucia
 LI Liechtenstein
 LK Sri Lanka
 LR Liberia
 LS Lesotho
 LT Lithuania
 LU Luxembourg
 LV Latvia
 LY Libya
 MA Morocco
 MC Monaco
 MD Moldova
 ME Montenegro
 MF Saint Martin
 MG Madagascar
 MH Marshall Islands
 MK Macedonia
 ML Mali
 MM Myanmar [Burma]
 MN Mongolia
 MO Macau SAR China
 MP Northern Mariana Islands
 MQ Martinique
 MR Mauritania
 MS Montserrat
 MT Malta
 MU Mauritius
 MV Maldives
 MW Malawi
 MX Mexico
 MY Malaysia
 MZ Mozambique
 NA Namibia
 NC New Caledonia
 NE Niger
 NF Norfolk Island
 NG Nigeria
 NI Nicaragua
 NL Netherlands
 NO Norway
 NP Nepal
 NR Nauru
 NU Niue
 NZ New Zealand
 OM Oman
 PA Panama
 PE Peru
 PF French Polynesia
 PG Papua New Guinea
 PH Philippines
 PK Pakistan
 PL Poland
 PM Saint Pierre and Miquelon
 PN Pitcairn Islands
 PR Puerto Rico
 PS Palestinian Territories
 PT Portugal
 PW Palau
 PY Paraguay
 QA Qatar
 RE Réunion
 RO Romania
 RS Serbia
 RU Russia
 RW Rwanda
 SA Saudi Arabia
 SB Solomon Islands
 SC Seychelles
 SD Sudan
 SE Sweden
 SG Singapore
 SH Saint Helena
 SI Slovenia
 SJ Svalbard and Jan Mayen
 SK Slovakia
 SL Sierra Leone
 SM San Marino
 SN Senegal
 SO Somalia
 SR Suriname
 ST São Tomé and Príncipe
 SV El Salvador
 SY Syria
 SZ Swaziland
 TC Turks and Caicos Islands
 TD Chad
 TF French Southern Territories
 TG Togo
 TH Thailand
 TJ Tajikistan
 TK Tokelau
 TL Timor-Leste
 TM Turkmenistan
 TN Tunisia
 TO Tonga
 TR Turkey
 TT Trinidad and Tobago
 TV Tuvalu
 TW Taiwan
 TZ Tanzania
 UA Ukraine
 UG Uganda
 UM U.S. Minor Outlying Islands
 US United States
 UY Uruguay
 UZ Uzbekistan
 VA Vatican City
 VC Saint Vincent and the Grenadines
 VE Venezuela
 VG British Virgin Islands
 VI U.S. Virgin Islands
 VN Vietnam
 VU Vanuatu
 WF Wallis and Futuna
 WS Samoa
 YE Yemen
 YT Mayotte
 ZA South Africa
 ZM Zambia
 ZW Zimbabwe
 @return string with the device country code (example: ES)
 */
+ (NSString *)languageDeviceCountryCode
{
    return [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
}


+ (NSString *)userTimezone
{
    return [[NSTimeZone localTimeZone] name];
}

+ (NSString *)applicationVersion
{
    NSBundle *pathApp = [NSBundle mainBundle];
    NSString *defaultPathPlist = [pathApp pathForResource:@"Info.plist" ofType: nil];
    NSDictionary *infoApp = [NSDictionary dictionaryWithContentsOfFile:defaultPathPlist];
    return [infoApp objectForKey:@"CFBundleVersion"];
}


+ (NSString *) carrierName {
    if (NSClassFromString(@"CTTelephonyNetworkInfo")!=nil){
        #if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
        CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [netinfo subscriberCellularProvider];        
        [netinfo autorelease];      
        if ([carrier carrierName])
            return [carrier carrierName];
        #endif
    }
    return @"";
}

+ (NSString *) platform {
    
    return @"IOS";
    
}

+ (CGRect)rectForViewScreen {
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        return CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen]bounds].size.height, [UIScreen mainScreen].bounds.size.width );
    }
    
    return CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen]bounds].size.width, [UIScreen mainScreen].bounds.size.height);
}


@end
