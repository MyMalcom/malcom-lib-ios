//
//  MCMLog.m
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 25/05/12.
//  Copyright (c) 2012 Malcom. All rights reserved.
//

#import "MCMLog.h"
#import "MCMCoreDefines.h"

@implementation MCMLog

+ (void)log:(NSString *)string inLine:(NSInteger)line fromMethod:(NSString *)method {
    
    BOOL logActivated = [[[NSUserDefaults standardUserDefaults] objectForKey:KMCMLogActivated] boolValue];
    
    if (logActivated) {
    
        NSLog(@"%@ [Line %d] %@", method, line, string);
        
    }
    
}

@end
