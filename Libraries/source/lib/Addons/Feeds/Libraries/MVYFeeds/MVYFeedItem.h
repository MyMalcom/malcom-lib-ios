//
//  MVYFeedItem.h
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MVYFeedItem : NSObject {
    NSString *title_;
	NSString *summary_;
	NSString *body_;
	NSString *link_;
    NSString *author_;
    NSDate *date_;
    NSMutableArray *images_;
    NSMutableArray *thumbnails_;
    NSMutableArray *captions_;
    NSMutableArray *credits_;
    NSMutableArray *categories_;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *thumbnails;
@property (nonatomic, retain) NSMutableArray *captions;
@property (nonatomic, retain) NSMutableArray *credits;
@property (nonatomic, retain) NSMutableArray *categories;

@end
