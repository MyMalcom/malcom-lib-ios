//
//  AdWhirlAdapterAdMobaloo.h
//  GasAll
//
//  Created by Alfonso Miranda Castro on 19/01/12.
//  Copyright (c) 2012 Mobivery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdWhirlAdNetworkAdapter.h"
#import "AdMobalooView.h"
#import "AdMobalooBannerDelegateProtocol.h"
#import "AdMobalooIntersitialDelegateProtocol.h"


@interface AdWhirlAdapterAdMobaloo : NSObject <AdMobalooBannerDelegate, AdMobalooIntersitialDelegate> {
    
    AdMobalooView *adMobalooAd;
    UIViewController *viewController_;
    BOOL didShowInterstitial_;
    AdWhirlView *adWhirlView_;
    
}

// Metodo para la creacion del singleton
+ (AdWhirlAdapterAdMobaloo *)sharedInstance;

+ (AdWhirlAdNetworkType)networkType;

- (id)initWithMobaloo:(AdWhirlView *)adWhirl;
- (void)showMobalooIntersitial:(UIViewController *) viewController;

@end
