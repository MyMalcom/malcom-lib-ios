//
//  Head.m
//  rss20
//
//  Created by Angel Garcia Olloqui on 09/02/09.
//  Copyright 2009 Mi Mundo iPhone. All rights reserved.
//

#import "Head.h"


@implementation Head

@synthesize title,dateCreated, dateModified, ownerName, ownerEmail, ownerId, docs, expansionState, vertScrollState, windowTop, windowLeft, windowBottom, windowRight;


- (void) dealloc {
	
	[title release];
	[dateCreated release];
	[dateModified release];
	[ownerName release];
	[ownerEmail release];
	[ownerId release];
	[docs release];
	[expansionState release];
	
	[super dealloc];
}


@end
