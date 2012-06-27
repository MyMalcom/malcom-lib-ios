//
//  MPMraidInterstitialAdapter.h
//  MoPub
//
//  Created by Andrew He on 12/11/11.
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPBaseInterstitialAdapter.h"
#import "MRAdView.h"

@interface MPMraidInterstitialAdapter : MPBaseInterstitialAdapter <MRAdViewDelegate> {
	MRAdView *_adView;
	BOOL _loaded;
}

@end
