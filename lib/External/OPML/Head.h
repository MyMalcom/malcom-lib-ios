//
//  Head.h
//  rss20
//
//  Created by Angel Garcia Olloqui on 09/02/09.
//  Copyright 2009 Mi Mundo iPhone. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Head : NSObject {
	
	NSString *title;
	NSDate *dateCreated;
	NSDate *dateModified;
	NSString *ownerName;
	NSString *ownerEmail;
	NSString *ownerId;
	NSString *docs;
	NSString *expansionState;
	NSInteger vertScrollState;
	NSInteger windowTop;
	NSInteger windowLeft;
	NSInteger windowBottom;
	NSInteger windowRight;
	
}


@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDate *dateCreated;
@property (nonatomic, copy) NSDate *dateModified;
@property (nonatomic, copy) NSString *ownerName;
@property (nonatomic, copy) NSString *ownerEmail;
@property (nonatomic, copy) NSString *ownerId;
@property (nonatomic, copy) NSString *docs;
@property (nonatomic, copy) NSString *expansionState;
@property (nonatomic, assign) NSInteger vertScrollState;		
@property (nonatomic, assign) NSInteger windowTop;		
@property (nonatomic, assign) NSInteger windowLeft;		
@property (nonatomic, assign) NSInteger windowBottom;		
@property (nonatomic, assign) NSInteger windowRight;


@end
