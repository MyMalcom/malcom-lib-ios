//
//  Body.m
//  rss20
//
//  Created by Angel Garcia Olloqui on 09/02/09.
//  Copyright 2009 Mi Mundo iPhone. All rights reserved.
//

#import "Body.h"


@implementation Body

@synthesize outlines;


- (id) init {
	self = [super init];
	if (self!=nil){
		outlines = [[NSMutableArray alloc] initWithCapacity:1];
	}
	return self;
}


- (void) addOutline:(Outline *)outline {
	[outline retain];
	[outlines addObject:outline];
}


- (Outline *) getOutlineWithText:(NSString *)text {
	for (Outline *out in outlines){
		Outline *found = [out getOutlineWithText:text];
		if (found!=nil){
			return found;
		}
	}
	return nil;
}


- (Outline *) getOutlineWithId:(NSString *)outlineId {
	for (Outline *out in outlines){
		Outline *found = [out getOutlineWithId:outlineId];
		if (found!=nil){
			return found;
		}
	}
	return nil;
}


- (void) dealloc {
	for (Outline *o in outlines)
		[o release];
	[outlines release];
	
	[super dealloc];
}

@end
