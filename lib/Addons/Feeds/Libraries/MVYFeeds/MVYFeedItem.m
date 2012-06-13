//
//  MVYFeedItem.m
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MVYFeedItem.h"


@implementation MVYFeedItem

@synthesize title=title_, summary=summary_, body=body_, link=link_, author=author_, date=date_, images=images_, thumbnails=thumbnails_, captions=captions_, credits=credits_, categories=categories_;


- (id) init{
    if (([super init])){
        images_=[[NSMutableArray alloc] init];
        thumbnails_=[[NSMutableArray alloc] init];
        captions_=[[NSMutableArray alloc] init];
        credits_=[[NSMutableArray alloc] init];
        categories_=[[NSMutableArray alloc] init];
    }

    return self;
}


- (void) dealloc{
    self.title=nil;
    self.summary=nil;
    self.body=nil;
    self.link=nil;
    self.author=nil;
    self.date=nil;
    self.images=nil;
    self.thumbnails=nil;
    self.captions=nil;
    self.credits=nil;
    self.categories=nil;

    [super dealloc];
}
@end
