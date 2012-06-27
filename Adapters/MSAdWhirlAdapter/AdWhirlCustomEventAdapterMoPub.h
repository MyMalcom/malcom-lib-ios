//
//  AdWhirlCustomEventAdapterMoPub.h
//  MoPubAdWhirl
//
//  Created by Nafis Jamal on 3/27/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdWhirlAdNetworkAdapter.h"
#import "MPAdView.h"
#import "AdWhirlView.h"

@interface AdWhirlCustomEventAdapterMoPub : NSObject <MPAdViewDelegate> {
	MPAdView *mpAdView;
	AdWhirlView *adWhirlView;
	id<AdWhirlDelegate> adWhirlDelegate;
	NSString *adUnitID;
}

@property (nonatomic,retain) MPAdView *mpAdView;
@property (nonatomic,retain) AdWhirlView *adWhirlView;
@property (nonatomic,assign) id<AdWhirlDelegate> adWhirlDelegate;
@property (nonatomic, assign) NSString *adUnitID;

/*
 Class method used to conventienty request a new ad from MoPub
 */
+ (AdWhirlCustomEventAdapterMoPub *)requestMoPubAdForAdUnitID:(NSString *)adUnitID_
										  withAdWhirlDelegate:(id<AdWhirlDelegate>)delegate
											   forAdWhirlView:(AdWhirlView *)view;

/*
 Init method used to request ad from mopub servers. This method should not explicity
 be called. Instead, please use the above convenience class method.
 */
- (id)initWithAdUnitId:(NSString *)adUnitID
   withAdwhirlDelegate:(id<AdWhirlDelegate>)delegate	
		forAdWhirlView:(AdWhirlView *)adWhirlView;

/*
 Similar to AdWhirl, this method should be called in -shouldAutorotateToInterfaceOrientation:
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;



@end
