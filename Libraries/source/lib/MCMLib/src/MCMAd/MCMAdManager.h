//
//  MCMAdManager.h
//  MobiveryApp
//
//  Created by Alfonso Miranda Castro on 20/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdWhirlView.h"


@interface MCMAdManager : NSObject<AdWhirlDelegate> {
    
    CGRect adWhirlFrame_;
    BOOL frameChanged_;
    AdWhirlView *adWhirlView_;
    UIViewController *viewController_;
    
}

@property(nonatomic, assign) BOOL frameChanged;

#pragma mark ----
#pragma mark  Public methods declaration
#pragma mark ----

/**
 Gets the singleton instance for this class
 @returns Singleton object for the class
 @since 1.0
 */
+ (MCMAdManager *)sharedInstance;

- (void)setAdWhirlFrame:(CGRect)adWhirlFrame;

- (CGRect)getAdWhirlFrame;

- (void)presentAd:(UIViewController *)vc atPosition:(CGRect)position;

@end
