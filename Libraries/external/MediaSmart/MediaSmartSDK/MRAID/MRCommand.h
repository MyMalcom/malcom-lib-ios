//
//  MRCommand.h
//  MoPub
//
//  Created by Andrew He on 12/19/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRAdView.h"

@interface MRAdView (MRCommand)

@property (nonatomic, retain, readonly) MRAdViewBrowsingController *browsingController;
@property (nonatomic, retain, readonly) MRAdViewDisplayController *displayController;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRCommand : NSObject {
    MRAdView *_view;
    NSDictionary *_parameters;
}

@property (nonatomic, assign) MRAdView *view;
@property (nonatomic, retain) NSDictionary *parameters;

+ (NSMutableDictionary *)sharedCommandClassMap;
+ (void)registerCommand:(Class)commandClass;
+ (NSString *)commandType;
+ (id)commandForString:(NSString *)string;

- (BOOL)execute;

- (CGFloat)floatFromParametersForKey:(NSString *)key;
- (CGFloat)floatFromParametersForKey:(NSString *)key withDefault:(CGFloat)defaultValue;
- (BOOL)boolFromParametersForKey:(NSString *)key;
- (int)intFromParametersForKey:(NSString *)key;
- (NSString *)stringFromParametersForKey:(NSString *)key;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRCloseCommand : MRCommand
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRExpandCommand : MRCommand
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRUseCustomCloseCommand : MRCommand
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MROpenCommand : MRCommand
@end
