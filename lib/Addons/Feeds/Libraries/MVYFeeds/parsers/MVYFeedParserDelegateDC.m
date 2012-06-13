//
//  MVYFeedParserDelegateDC.m
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 07/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MVYFeedParserDelegateDC.h"

static NSString *kCreator = @"creator";


@implementation MVYFeedParserDelegateDC


- (void) didStartElement:(NSString *)element attributes:(NSDictionary *)attributeDict feed:(MVYFeed *)feed{
   // MVYFeedItem *item = [feed.items lastObject];    
}

- (void) didEndElement:(NSString *)element feed:(MVYFeed *)feed currentString:(NSString *)currentString{
    MVYFeedItem *item = [feed.items lastObject];    
    if ([element isEqualToString:kCreator]){
        if ([currentString length]>0)
            item.author=currentString;
	}
   
    
}

@end
