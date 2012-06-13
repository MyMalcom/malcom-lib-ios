//
//  OPML.h
//  rss20
//
//  Created by Angel Garcia Olloqui on 09/02/09.
//  Copyright 2009 Mi Mundo iPhone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Body.h"
#import "Head.h"

@interface OPML : NSObject {

	Head *head;
	Body *body;
}


@property (nonatomic, retain) Head *head;
@property (nonatomic, retain) Body *body;


@end
