//
//  Outline.m
//  rss20
//
//  Created by Angel Garcia Olloqui on 09/02/09.
//  Copyright 2009 Mi Mundo iPhone. All rights reserved.
//

#import "Outline.h"


@implementation Outline

@synthesize outlines, text, type, isComment, isBreakpoint, created, category, description, language, title, version, xmlUrl, htmlUrl, url, outlineId;


- (void) addOutline:(Outline *)outline {
	if (outlines ==nil)
		outlines = [[NSMutableArray alloc] initWithCapacity:1];
	[outline retain];
	[outlines addObject:outline];
}


- (Outline *) getOutlineWithText:(NSString *)textSearch {
	if ([self.text isEqualToString:textSearch])
		return self;
	
	for (Outline *out in outlines){
		Outline *found = [out getOutlineWithText:textSearch];
		if (found!=nil){
			return found;
		}
	}
	return nil;
}

- (Outline *) getOutlineWithId:(NSString *)searchId {
	if ([self.outlineId isEqualToString:searchId])
		return self;
	
	for (Outline *out in outlines){
		Outline *found = [out getOutlineWithId:searchId];
		if (found!=nil){
			return found;
		}
	}
	return nil;
}

- (void) dealloc {
	
	[text release];
	[type release];
	[created release];
	[category release];
	[description release];
	[language release];
	[title release];
	[version release];
	[xmlUrl release];
	[htmlUrl release];
	[url release];
	[outlineId release];
	
	for (Outline *o in outlines)
		[o release];
	[outlines release];
	
	[super dealloc];
}

@end
