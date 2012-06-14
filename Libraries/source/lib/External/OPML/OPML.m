//
//  OPML.m
//  rss20
//
//  Created by Angel Garcia Olloqui on 09/02/09.
//  Copyright 2009 Mi Mundo iPhone. All rights reserved.
//

#import "OPML.h"


@implementation OPML

@synthesize head, body;

- (id) init{

	self = [super init];
	if (self != nil){
		head = [[Head alloc] init];
		body = [[Body alloc] init];
	}
	return self;
}


- (void) dealloc {
	
	[head release];
	[body release];
	
	[super dealloc];
}


@end
