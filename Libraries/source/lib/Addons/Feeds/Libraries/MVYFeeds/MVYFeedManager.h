//
//  MVYFeedManager.h
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVYFeed.h"

@interface MVYFeedManager : NSObject {    
    NSMutableDictionary *loadedFeeds_;    
}

+ (MVYFeedManager *)sharedInstance;

- (MVYFeed *)feedForURL:(NSURL *)url;

- (void) updateFeed:(MVYFeed *)feed;

@end
