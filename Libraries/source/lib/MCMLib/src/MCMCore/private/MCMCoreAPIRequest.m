
#import "MCMCoreAPIRequest.h"
#import "MCMCore.h"
#import "MCMCoreDefines.h"
#import "MCMhmac.h"
#import "MCMBase64Transcoder.h"
#import <CommonCrypto/CommonHMAC.h>

@interface MCMCoreAPIRequest(private)

+ (NSString *)signatureWithKey:(NSString *)secret verb:(NSString *)verb contentMD5:(NSString *)md5 contentType:(NSString *)type date:(NSString *)date canonicalizedMcmHeaders:(NSString *)canMcmHeaders canonicalizedResource:(NSString *)canResource;

+ (NSDateFormatter*)MCMCoreAPIRequestDateFormatter;

- (NSString *)canonalizedMcmHeaders;

- (NSString *) contentMD5;

@end


@implementation MCMCoreAPIRequest




- (void)buildRequestHeaders{
    [super buildRequestHeaders];
    
    //Get the key
    NSString *key = [[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyAssetsAppSecretKey];
    
    //Get the verb
    NSString *verb = [self requestMethod];
    
    //Get content type    
    NSString *type = nil;
    for (NSString *header in [self requestHeaders]){
        if ([[header lowercaseString] isEqualToString:@"content-type"])
            type = [[self requestHeaders] valueForKey:header];
    }    
    
    //Get canonicalized resource path
    NSString *canResource = [[self url] path];

    //Set the x-mcm-date parameter (ignore the standard Date parameter because it can contain incorrect data)
    NSString *mcmDdateString = [[[MCMCoreAPIRequest MCMCoreAPIRequestDateFormatter] stringFromDate:[NSDate date]] stringByAppendingString:@" GMT"];
        
	[self addRequestHeader:@"x-mcm-date" value:mcmDdateString];

    //Calculate body MD5
    NSString *md5 = [self contentMD5];
    if (md5)
        [self addRequestHeader:@"Content-MD5" value:md5];
    
    //Generate canonicalized Malcom headers
    NSString *canMcmHeaders = [self canonalizedMcmHeaders];

    //Generate the signature
    NSString *signature = [MCMCoreAPIRequest signatureWithKey:key verb:verb contentMD5:md5 contentType:type date:@"" canonicalizedMcmHeaders:canMcmHeaders canonicalizedResource:canResource];
    //Sign the request
    if (signature){
        [self setAuthenticationScheme:(NSString *) kCFHTTPAuthenticationSchemeBasic];
        [self setUsername:[[MCMCoreManager sharedInstance] valueForKey:kMCMCoreKeyMalcomAppId]];
        [self setPassword:signature];
        [self setUseSessionPersistence:NO];
        [self setUseKeychainPersistence:NO]; 
        [self setUseCookiePersistence:NO]; 
    }
 
}

- (NSString *)canonalizedMcmHeaders
{
    //Get all headers
    id allHeaders = [self requestHeaders];
    //Filter the malcom headers
	NSMutableArray *mcmHeaders = [NSMutableArray array];
    for (NSString *header in allHeaders){
        if ([header rangeOfString:@"x-mcm-"].location==0){      
            [mcmHeaders addObject:header];
        }
    }
    [mcmHeaders sortUsingSelector:@selector(compare:)];
    
    //Compose the malcom canonicalized header
    NSString *canonicalizedMcmHeader = @"";
    for (NSString *header in mcmHeaders) {
		canonicalizedMcmHeader = [canonicalizedMcmHeader stringByAppendingFormat:@"\n%@:%@",[header lowercaseString],[allHeaders objectForKey:header]];
	}   
    //Remove the first \n if it exists
    if ([canonicalizedMcmHeader length]>0)
        return [canonicalizedMcmHeader substringFromIndex:1];
    else
        return canonicalizedMcmHeader;
}

- (NSString *) contentMD5{
    if ([[self postBody] length]<=0)
        return nil;
    
    NSString *body = [[NSString alloc] initWithData:[self postBody] encoding:NSUTF8StringEncoding];
    
    const char *cStr = [body UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    //Base64 Encoding    
    char base64Result[32];
    size_t theResultLength = 32;
    MCMBase64EncodeData(result, 16, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    
    [body release];
    return [base64EncodedResult autorelease];        
}
   

/*
 hmac-sha1(VERB + "\n"
+ CONTENT-MD5 + "\n"
+ CONTENT-TYPE + "\n"
+ DATE + "\n"
+ CanonicalizedMcmHeaders + "\n"
+ URL)
 */
+ (NSString *)signatureWithKey:(NSString *)secret verb:(NSString *)verb contentMD5:(NSString *)md5 contentType:(NSString *)type date:(NSString *)date canonicalizedMcmHeaders:(NSString *)canMcmHeaders canonicalizedResource:(NSString *)canResource{
    
    //check headers
    if ((secret==nil) || (verb==nil) || (canResource==nil))
        return nil;
    if (date==nil) date=@"";
    if (md5==nil) md5=@"";
    if (type==nil) type=@"";
    if (canMcmHeaders==nil) canMcmHeaders=@"";
    
    //Compose string to sign
    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@", verb, md5, type, date, canMcmHeaders, canResource];
    
    //SHA1
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [stringToSign dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    MCMhmac_sha1((unsigned char *)[clearTextData bytes], [clearTextData length], (unsigned char *)[secretData bytes], [secretData length], result);
    
    //Base64 Encoding    
    char base64Result[32];
    size_t theResultLength = 32;
    MCMBase64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    
    return [base64EncodedResult autorelease];    
}


+ (NSDateFormatter*)MCMCoreAPIRequestDateFormatter
{
	NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
	NSDateFormatter *dateFormatter = [threadDict objectForKey:@"MCMCoreAPIRequestDateFormatter"];
	if (dateFormatter == nil) {
		dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		// Prevent problems with dates generated by other locales (tip from: http://rel.me/t/date/)
		[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
		[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss"];
		[threadDict setObject:dateFormatter forKey:@"MCMCoreAPIRequestDateFormatter"];
	}
	return dateFormatter;	
}

@end
