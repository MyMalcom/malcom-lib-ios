//
//  OPMLReader.h
//  rss20
//
//  Created by Angel Garcia Olloqui on 02/02/09.
//  Copyright 2009 Mi Mundo iPhone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OPML.h"
#import "OPML20ParserDelegate.h"

@interface OPMLReader : NSObject 
#ifdef __IPHONE_4_0
<NSXMLParserDelegate>
#endif
{
@private
	
	OPML *opml;
	
	NSMutableString *currentString;
	NSMutableArray *elementStack;
	NSMutableArray *attributesStack;
	OPML20ParserDelegate *parser;
}

- (id)initWithUrl:(NSURL *)url;
- (id) initWithData:(NSData *)data;

@property (nonatomic, retain) OPML *opml;

@end
