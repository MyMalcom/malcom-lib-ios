//
//  MVYFeedParser.m
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MVYFeedParser.h"

@interface MVYFeedParser (private)

- (NSObject<MVYFeedParserDelegateProtocol> *) parserForURI:(NSString *)uri;

@end

@implementation MVYFeedParser

@synthesize error;

- (void) dealloc{
    [feed_ release]; feed_=nil;
    [xmlParser_ release]; xmlParser_=nil;
    [nsDelegates_ release]; nsDelegates_=nil;
    [feedParsers_ release]; feedParsers_=nil;
    [super dealloc];
}

- (id) initWithData:(NSData *)data feed:(MVYFeed *)feed{    
	self = [super init];    
	if (self != nil) {		                
        self.error=NO;
        feed_ = [feed retain];

        //Parseador de XML
        xmlParser_ = [[NSXMLParser alloc] initWithData:data];
        [xmlParser_ setShouldProcessNamespaces:YES];
        xmlParser_.delegate = self;        
        
        //Delegados
        nsDelegates_ = [[NSMutableDictionary alloc] init];        
        
        //Read the config file       
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"MVYFeedParsers" ofType:@"plist"];
        if (bundlePath==nil){        
            [[NSException exceptionWithName:@"MVYFeedParsers not found" reason:@"There is no MVYFeedParsers file in the bundle. You should include a configuration file named MVYFeedParsers.plist with the available parsers in your library" userInfo:nil] raise];        
        }
        
        feedParsers_ = [[NSDictionary alloc] initWithContentsOfFile:bundlePath];	
	}	
	return self;
}

- (void) parse{    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];    
    [xmlParser_ parse];    
    [pool release];
}


- (NSObject<MVYFeedParserDelegateProtocol> *) parserForURI:(NSString *)uri{
    id parserDelegate = [nsDelegates_ valueForKey:uri];
    if (parserDelegate==nil){
                
        NSString *parserName = [feedParsers_ valueForKey:uri];
        if (parserName==nil) return nil;
        
        //Create delegate
        parserDelegate = [[[NSClassFromString(parserName) alloc] init] autorelease];
        
        //add the delegate to the delegates dictionary for the next time
        if (parserDelegate){
            [nsDelegates_ setValue:parserDelegate forKey:uri];
        }    
    }

    return parserDelegate;    
}


#pragma mark parserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qualifiedName attributes:(NSDictionary *)attributeDict {
	
    [currentString_ release];
	currentString_ = [[NSMutableString alloc] init];
	    
    NSObject<MVYFeedParserDelegateProtocol> *parserDelegate = [self parserForURI:namespaceURI];    
    if (parserDelegate){
        [parserDelegate didStartElement:elementName attributes:attributeDict feed:feed_];
    }    
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

    NSObject<MVYFeedParserDelegateProtocol> *parserDelegate = [self parserForURI:namespaceURI];    
    if (parserDelegate){
        [parserDelegate didEndElement:elementName feed:feed_ currentString:currentString_];
    }    
    [currentString_ release]; currentString_=nil;
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([string isKindOfClass:[NSString class]])
		[currentString_ appendString:string];
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"parseErrorOccurred: %@", [parseError description]);
    self.error=YES;
}


@end
