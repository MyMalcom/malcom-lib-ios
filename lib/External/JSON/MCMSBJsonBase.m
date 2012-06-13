//
//  SBJsonBase.m
//  JSON
//
//  Created by Stig Brautaset on 18/03/2009.
//  Copyright 2009 Stig Brautaset. All rights reserved.
//

#import "MCMSBJsonBase.h"
NSString * MCMSBJSONErrorDomain = @"org.brautaset.JSON.ErrorDomain";


@implementation MCMSBJsonBase

@synthesize errorTrace;

- (void)dealloc {
    [errorTrace release];
    [super dealloc];
}

- (void)addErrorWithCode:(NSUInteger)code description:(NSString*)str {
    NSDictionary *userInfo;
    if (!errorTrace) {
        errorTrace = [NSMutableArray new];
        userInfo = [NSDictionary dictionaryWithObject:str forKey:NSLocalizedDescriptionKey];
        
    } else {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    str, NSLocalizedDescriptionKey,
                    [errorTrace lastObject], NSUnderlyingErrorKey,
                    nil];
    }
    
    NSError *error = [NSError errorWithDomain:MCMSBJSONErrorDomain code:code userInfo:userInfo];

    [self willChangeValueForKey:@"errorTrace"];
    [errorTrace addObject:error];
    [self didChangeValueForKey:@"errorTrace"];
}

- (void)clearErrorTrace {
    [self willChangeValueForKey:@"errorTrace"];
    errorTrace = nil;
    [self didChangeValueForKey:@"errorTrace"];
}

@end
