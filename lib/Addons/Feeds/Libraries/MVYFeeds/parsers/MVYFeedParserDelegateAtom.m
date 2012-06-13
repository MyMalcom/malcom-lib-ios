//
//  MVYFeedParserDelegateAtom.m
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MVYFeedParserDelegateAtom.h"


//Creacion de variables estaticas para evitar crearlas en ejecucion multiples veces
static NSString *kItem = @"entry";
static NSString *kTitle = @"title";
static NSString *kSummary = @"summary";
static NSString *kContent = @"content";
static NSString *kLink = @"link";
static NSString *kAuthor = @"author";
static NSString *kAuthorName = @"name";
static NSString *kDate = @"published";
static NSString *kCategory = @"category";



@implementation MVYFeedParserDelegateAtom


- (id) init {
    if ((self=[super init])){
        parseFormatter_ = [[NSDateFormatter alloc] init];
		[parseFormatter_ setFormatterBehavior:NSDateFormatterBehaviorDefault];
		[parseFormatter_ setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease]];
		[parseFormatter_ setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];		
        inAuthor_=NO;
    }
    return self;
}


- (void) dealloc{
    [parseFormatter_ release];
    
    [super dealloc];
}

- (void) didStartElement:(NSString *)element attributes:(NSDictionary *)attributeDict feed:(MVYFeed *)feed{
    MVYFeedItem *item = [feed.items lastObject];    
    
	if ([element isEqualToString:kItem]){
        MVYFeedItem *item = [[MVYFeedItem alloc] init];
        [[feed items] addObject:item];
        [item release];
	}
    else if ([element isEqualToString:kLink]){
        NSString *rel =[attributeDict valueForKey:@"rel"];
        if ([rel length]<=0)
            rel=@"alternate";
        
        if ([rel isEqualToString:@"alternate"]){
            if ([[attributeDict valueForKey:@"href"] length]>0)
                item.link=[attributeDict valueForKey:@"href"];	     
        }
        else if ([rel isEqualToString:@"enclosure"]){
            if ([[attributeDict valueForKey:@"type"] rangeOfString:@"image"].location!=NSNotFound){
                if ([[attributeDict valueForKey:@"href"] length]>0)
                    [item.images addObject:[attributeDict valueForKey:@"href"]];    
            }
        }        
	}
    else if ([element isEqualToString:kCategory]){
        if ([[attributeDict valueForKey:@"term"] length]>0)
            [item.categories addObject:[attributeDict valueForKey:@"term"]];	
	}
    else if ([element isEqualToString:kAuthor]){
        inAuthor_=YES;
    }
}

- (void) didEndElement:(NSString *)element feed:(MVYFeed *)feed currentString:(NSString *)currentString{
    
    MVYFeedItem *item = [feed.items lastObject];    
    if ([element isEqualToString:kTitle]){
        item.title=currentString;
	}
    else if ([element isEqualToString:kSummary]){
        item.summary=currentString;
	}
    else if ([element isEqualToString:kContent]){
        item.body=currentString;
	}
    else if ([element isEqualToString:kDate]){
        item.date=[parseFormatter_ dateFromString:currentString];	
	}    
    else if ([element isEqualToString:kAuthor]){
        inAuthor_=NO;
    }
    else if ([element isEqualToString:kAuthorName]){
        if (inAuthor_)
            item.author=currentString;
    }   
}

@end
