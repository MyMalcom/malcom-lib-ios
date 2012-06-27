//
//  MCMAdManager+CustomEvent.m
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 11/05/12.
//  Copyright (c) 2012 Malcom. All rights reserved.
//

#import "MCMAdManager+CustomEvent.h"
#import "MadvertiseAdWhirlAdapter.h"
#import "MalcomLib.h"

@implementation MCMAdManager (CustomEvent)


- (void)AdWhirlCustomEventMadvertise:(AdWhirlView *)adWhirlView {
    
    [adWhirlView setHidden:NO];
    CGSize adSize = [adWhirlView actualAdSize];
    
    CGRect rect = CGRectMake((adWhirlView.superview.frame.size.width-adSize.width)/2, adWhirlView.superview.frame.size.height-adSize.height, adSize.width, adSize.height);
    

    [adWhirlView setFrame:rect];
    [[MadvertiseAdWhirlAdapter sharedInstance] initWithMadvertise:adWhirlView];
    
}

@end
