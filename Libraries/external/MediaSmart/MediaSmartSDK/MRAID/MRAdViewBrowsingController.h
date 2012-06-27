//
//  MRAdViewBrowsingController.h
//  MoPub
//
//  Created by Andrew He on 12/22/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdBrowserController.h"

@class MRAdView;

@interface MRAdViewBrowsingController : NSObject <MPAdBrowserControllerDelegate> {
    MRAdView *_view;
    UIViewController *_viewControllerForPresentingModalView;
}

@property (nonatomic, assign) UIViewController *viewControllerForPresentingModalView;

- (id)initWithAdView:(MRAdView *)adView;
- (void)openBrowserWithUrlString:(NSString *)urlString enableBack:(BOOL)back
                   enableForward:(BOOL)forward enableRefresh:(BOOL)refresh;

@end
