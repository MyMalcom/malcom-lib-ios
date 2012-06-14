//
//  MVYFeed.h
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVYFeedItem.h"

@interface MVYFeed : NSObject {
    NSMutableArray *items_;
    NSDate *lastUpdate_;
    NSURL *url_;
    BOOL updating_;
    BOOL error_;
}

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSDate *lastUpdate;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) BOOL updating;
@property (nonatomic, assign) BOOL error;

@end
