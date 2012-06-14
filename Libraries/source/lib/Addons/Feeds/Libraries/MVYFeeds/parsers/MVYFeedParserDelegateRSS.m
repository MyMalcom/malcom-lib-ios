//
//  MVYFeedParserDelegateRSS.m
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MVYFeedParserDelegateRSS.h"



//Creacion de variables estaticas para evitar crearlas en ejecucion multiples veces
static NSString *kItem = @"item";
static NSString *kTitle = @"title";
static NSString *kDescription = @"description";
static NSString *kLink = @"link";
static NSString *kAuthor = @"author";
static NSString *kPubDate = @"pubDate";
static NSString *kCategory = @"category";
static NSString *kEnclousure = @"enclosure";



@implementation MVYFeedParserDelegateRSS


- (id) init {
    if ((self=[super init])){
        parseFormatter_ = [[NSDateFormatter alloc] init];
		[parseFormatter_ setFormatterBehavior:NSDateFormatterBehaviorDefault];
		[parseFormatter_ setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease]];
		[parseFormatter_ setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];		
    }
    return self;
}


- (void) dealloc{
    [parseFormatter_ release];

    [super dealloc];
}

- (void) didStartElement:(NSString *)element attributes:(NSDictionary *)attributeDict feed:(MVYFeed *)feed{
    
	if ([element isEqualToString:kItem]){
        MVYFeedItem *item = [[MVYFeedItem alloc] init];
        [[feed items] addObject:item];
        [item release];
	}
    else if ([element isEqualToString:kEnclousure]){
        MVYFeedItem *item = [feed.items lastObject];    
        if ([[attributeDict valueForKey:@"url"] length]>0)
            [item.images addObject:[attributeDict valueForKey:@"url"]];	
	}
    
}

- (void) didEndElement:(NSString *)element feed:(MVYFeed *)feed currentString:(NSString *)currentString{

    MVYFeedItem *item = [feed.items lastObject];    
    if ([element isEqualToString:kTitle]){
        item.title=currentString;
	}
    else if ([element isEqualToString:kLink]){
        item.link=currentString;
	}
    else if ([element isEqualToString:kDescription]){
        item.body=currentString;
	}
    else if ([element isEqualToString:kAuthor]){
        item.author=currentString;
	}
    else if ([element isEqualToString:kPubDate]){
        item.date=[parseFormatter_ dateFromString:currentString];	
	}
    else if ([element isEqualToString:kCategory]){
        if ([currentString length]>0)
            [item.categories addObject:currentString];	
	}
    
    
}

@end
