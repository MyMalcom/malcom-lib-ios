//
//  MVYFeedParser.h
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVYFeed.h"

@protocol MVYFeedParserDelegateProtocol <NSObject>

- (void) didStartElement:(NSString *)element attributes:(NSDictionary *)attributeDict feed:(MVYFeed *)feed;
- (void) didEndElement:(NSString *)element feed:(MVYFeed *)feed currentString:(NSString *)currentString;

@end


#if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
@interface MVYFeedParser : NSObject<NSXMLParserDelegate> {
#else
@interface MVYFeedParser : NSObject {
#endif
                
    MVYFeed *feed_;
    NSMutableString *currentString_;
    NSXMLParser *xmlParser_;    
    NSMutableDictionary *nsDelegates_;
    NSDictionary *feedParsers_;
}

@property BOOL error;
    
- (id) initWithData:(NSData *)data feed:(MVYFeed *)feed;    
- (void) parse;
    
@end
