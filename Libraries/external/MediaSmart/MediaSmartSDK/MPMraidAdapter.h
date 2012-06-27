//
//  MPMraidAdapter.h
//  MoPub
//
//  Created by Andrew He on 10/29/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import "MPBaseAdapter.h"
#import "MRAdView.h"

@interface MPMraidAdapter : MPBaseAdapter <MRAdViewDelegate> {
    MRAdView *_adView;
}

@end
