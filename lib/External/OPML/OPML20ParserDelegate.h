//
//  OPML20ParserDelegate.h
//  rss20
//
//  Created by Angel Garcia Olloqui on 04/02/09.
//  Copyright 2009 Mi Mundo iPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OPML.h"
#import "Outline.h"


@interface OPML20ParserDelegate : NSObject {
	
	NSDateFormatter *parseFormatter;
	OPML *opml;
	NSMutableArray *outlines;
}


@property (nonatomic, assign) NSDateFormatter *parseFormatter;
@property (nonatomic, assign) OPML *opml;
@property (nonatomic, readonly) NSMutableArray *outlines;


- (void) initElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qName:(NSString *)qName attributes:(NSDictionary *)attributeDict parent:(NSString *)parent;
- (void) parseElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qName:(NSString *)qName attributes:(NSDictionary *)attributeDict parent:(NSString *)parent currentString:(NSString *)currentString;

- (void) executeSetter:(NSString *)name objeto:(NSObject *)objeto currentString:(NSString *)currentString;
- (void) executeSettersFromDict:(NSObject *)objeto dict:(NSDictionary *)dict;

- (id) allocNewInstanceFromAndRelease:(id)instance;

@end
