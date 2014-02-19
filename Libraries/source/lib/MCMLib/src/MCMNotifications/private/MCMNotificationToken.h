//
//  MCMNotificationToken.h
//  MalcomLibProject
//
//  Created by Guillermo Ceballos on 05/02/14.
//  Copyright (c) 2014 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMNotificationToken : NSObject

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSDate *dateSaved;

@end
