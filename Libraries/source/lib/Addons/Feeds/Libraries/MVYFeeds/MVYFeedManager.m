//
//  MVYFeedManager.m
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MVYFeedManager.h"
#import "MCMASIHTTPRequest.h"
#import "MCMASIDownloadCache.h"
#import "MVYFeedParser.h"

@interface MVYFeedManager (private) <MCMASIHTTPRequestDelegate>

@end

@implementation MVYFeedManager

- (id) init {
	self = [super init];
	if (self!=nil) {		
		loadedFeeds_ = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (MVYFeed *)feedForURL:(NSURL *)url{
 	if (url==nil) return nil;
	
	MVYFeed *feed = [loadedFeeds_ objectForKey:url];
	if (feed==nil){	
		feed = [[MVYFeed alloc] init];	
		feed.url=url;	
		[loadedFeeds_ setObject:feed forKey:url];	
		[feed release];
        
        [self updateFeed:feed];	
	}	
	return feed;
}

- (void) updateFeed:(MVYFeed *)feed{
    
    if (feed.updating==NO){
        feed.updating=YES;
        
        //Try to read the cache for previous responses
        if ([feed.items count]==0){
            NSData *data = [[MCMASIDownloadCache sharedCache] cachedResponseDataForURL:feed.url];
            if (data){
                MVYFeedParser *parser = [[MVYFeedParser alloc] initWithData:data feed:feed];
                [parser parse];
                [parser release];
                
                //Set the date from cache
                NSString *filePath = [[MCMASIDownloadCache sharedCache] pathToCachedResponseDataForURL:feed.url];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    // retrieve file attributes
                    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
                    if (attributes != nil) {
                        feed.lastUpdate = [attributes fileModificationDate];
                    }
                }
            }
        }
        
        //Request new data
        MCMASIHTTPRequest *request = [MCMASIHTTPRequest requestWithURL:feed.url];
        [request setDownloadCache:[MCMASIDownloadCache sharedCache]];
        [request setCachePolicy:ASIAskServerIfModifiedCachePolicy];
        [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
        [request setTimeOutSeconds:30];
        [request setDelegate:self];
        [request startAsynchronous];        
    }
    
}





#pragma mark ----
#pragma mark ASIHTTPRequest delegate methods
#pragma mark ----


- (void)requestFinished:(MCMASIHTTPRequest *)request
{
    BOOL error = NO;

    //Get the feed
    MVYFeed *feed = [self feedForURL:[request originalURL]];
    
    if ([request didUseCachedResponse]==NO){
        // Use when fetching binary data
        NSData *data = [request responseData];
        
        //Check there is data
        if ([data length]<=0){
            [self requestFailed:request];
            return;
        }
     
        //Parse the response        
        MVYFeedParser *parser = [[MVYFeedParser alloc] initWithData:data feed:feed];
        [parser parse];
        error = [parser error];
        [parser release];        
    }
    
    if (error==NO){
        [feed setLastUpdate:[NSDate date]]; 
    }
    [feed setError:error];
    [feed setUpdating:NO];
}

- (void)requestFailed:(MCMASIHTTPRequest *)request
{
    NSError *err = [request error];
    NSLog(@"Error updating feeds for URL %@: %@", [[request originalURL] absoluteString], [err description]);
    
    //Get the feed
    MVYFeed *feed = [self feedForURL:[request originalURL]];   
    [feed setError:YES];
    [feed setUpdating:NO];    
}


#pragma mark Metodos del singleton
static MVYFeedManager *sharedInstance = nil;

+ (MVYFeedManager *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init]; 
        }
    }
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}
@end
