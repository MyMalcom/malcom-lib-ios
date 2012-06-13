//
//  Body.h
//  rss20
//
//  Created by Angel Garcia Olloqui on 09/02/09.
//  Copyright 2009 Mi Mundo iPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Outline.h"

@interface Body : NSObject {

	NSMutableArray *outlines;
}

@property(nonatomic, readonly)	NSMutableArray *outlines;


- (void) addOutline:(Outline *)outline ;

- (Outline *) getOutlineWithText:(NSString *)text;
- (Outline *) getOutlineWithId:(NSString *)outlineId;

@end
