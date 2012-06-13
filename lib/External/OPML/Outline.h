//
//  Outline.h
//  rss20
//
//  Created by Angel Garcia Olloqui on 09/02/09.
//  Copyright 2009 Mi Mundo iPhone. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Outline : NSObject {
	NSMutableArray *outlines;
	
	NSString *text;
	NSString *type;
	BOOL isComment;
	BOOL isBreakpoint;
	NSDate *created;
	NSString *category;
	NSString *description;
	NSString *language;
	NSString *title;
	NSString *version;	
	NSString *xmlUrl;
	NSString *htmlUrl;
	NSString *url;
	NSString *outlineId;
}

@property(nonatomic, readonly)	NSMutableArray *outlines;

@property(nonatomic,copy) NSString *text;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,assign) BOOL isComment;
@property(nonatomic,assign) BOOL isBreakpoint;
@property(nonatomic,copy) NSDate *created;
@property(nonatomic,copy) NSString *category;
@property(nonatomic,copy) NSString *description;
@property(nonatomic,copy) NSString *language;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *version;
@property(nonatomic,copy) NSString *xmlUrl;
@property(nonatomic,copy) NSString *htmlUrl;
@property(nonatomic,copy) NSString *url;
@property(nonatomic,copy) NSString *outlineId;


- (void) addOutline:(Outline *)outline ;

- (Outline *) getOutlineWithText:(NSString *)text;
- (Outline *) getOutlineWithId:(NSString *)outlineId;

@end
