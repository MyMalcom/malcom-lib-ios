//
//  MCMLog.h
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 25/05/12.
//  Copyright (c) 2012 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMLog : NSObject

+ (void)log:(NSString *)string inLine:(NSInteger)line fromMethod:(NSString *)method __attribute__ ((deprecated("Use MCMLog() instead")));

@end
