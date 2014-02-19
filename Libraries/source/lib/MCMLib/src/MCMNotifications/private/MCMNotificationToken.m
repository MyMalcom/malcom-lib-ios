//
//  MCMNotificationToken.m
//  MalcomLibProject
//
//  Created by Guillermo Ceballos on 05/02/14.
//  Copyright (c) 2014 Malcom. All rights reserved.
//

#import "MCMNotificationToken.h"

@implementation MCMNotificationToken

@synthesize token, dateSaved;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.token forKey:@"token"];
    [encoder encodeObject:self.dateSaved forKey:@"dateSaved"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.token = [decoder decodeObjectForKey:@"token"];
        self.dateSaved = [decoder decodeObjectForKey:@"dateSaved"];
    }
    return self;
}

@end
