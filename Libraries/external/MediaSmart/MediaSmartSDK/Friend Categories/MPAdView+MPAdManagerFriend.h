//
//  MPAdView+MPAdManagerFriend.h
//  MoPub
//
//  Created by Haydn Dufrene on 6/22/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPAdManager.h"
#import "MPAdView.h"

@interface MPAdView (MPAdManagerFriend)

@property (nonatomic, retain) MPAdManager *adManager;
@property (nonatomic, retain) UIView *adContentView;
@property (nonatomic, assign) CGSize originalSize;

- (void)backFillWithNothing;

@end
