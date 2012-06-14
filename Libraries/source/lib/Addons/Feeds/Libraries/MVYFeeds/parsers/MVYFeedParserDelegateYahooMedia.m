//
//  MVYFeedParserDelegateYahooMedia.m
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MVYFeedParserDelegateYahooMedia.h"

static NSString *kDescription = @"description";
static NSString *kThumbnail = @"thumbnail";
static NSString *kTitle = @"title";
static NSString *kContent = @"content";
static NSString *kCredit = @"credit";
static NSString *kCategory = @"category";

@implementation MVYFeedParserDelegateYahooMedia


- (void) didStartElement:(NSString *)element attributes:(NSDictionary *)attributeDict feed:(MVYFeed *)feed{
    MVYFeedItem *item = [feed.items lastObject];    
    if ([element isEqualToString:kThumbnail]){
        if ([[attributeDict valueForKey:@"url"] length]>0)
            [item.thumbnails addObject:[attributeDict valueForKey:@"url"]];
	}
    else if ([element isEqualToString:kContent]){
        if ([[attributeDict valueForKey:@"url"] length]>0)
            [item.images addObject:[attributeDict valueForKey:@"url"]];
	}

}

- (void) didEndElement:(NSString *)element feed:(MVYFeed *)feed currentString:(NSString *)currentString{
    MVYFeedItem *item = [feed.items lastObject];    
    if ([element isEqualToString:kDescription]){
        if ([currentString length]>0)
            [item.captions addObject:currentString];
	}
    else if ([element isEqualToString:kTitle]){
        if ([currentString length]>0)
            [item.captions addObject:currentString];
	}
    else if ([element isEqualToString:kCredit]){
        if ([currentString length]>0)
            [item.credits addObject:currentString];
	}
    else if ([element isEqualToString:kCategory]){
        if ([currentString length]>0)
            [item.categories addObject:currentString];
	}

}

@end
