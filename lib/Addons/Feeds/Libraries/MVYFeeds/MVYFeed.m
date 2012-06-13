//
//  MVYFeed.m
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MVYFeed.h"


@implementation MVYFeed

@synthesize items=items_, lastUpdate=lastUpdate_, url=url_, updating=updating_, error=error_;

- (id) init {
    if ((self=[super init])){
        items_=[[NSMutableArray alloc] init];
        self.updating=NO;
        self.error=NO;
    }
    return self;
}

- (void) dealloc {
    self.items=nil;
    self.lastUpdate=nil;
    self.url=nil;

    [super dealloc];
}

@end
