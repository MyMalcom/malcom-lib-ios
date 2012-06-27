//
//  AdWhirlCustomEventAdapterMoPub.m
//  MoPubAdWhirl
//
//  Created by Nafis Jamal on 3/27/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import "AdWhirlCustomEventAdapterMoPub.h"

#import "AdWhirlAdNetworkAdapter+Helpers.h"
#import "AdWhirlView.h"
#import "AdWhirlView+.h"
#import "MPAdView.h"


@interface AdWhirlCustomEventAdapterMoPub (Internal)

- (void)getAd;
- (NSString *)mopubKeywords;
- (NSInteger)calculateAgeFromDateOfBirth:(NSDate *)birth;

@end


@implementation AdWhirlCustomEventAdapterMoPub

@synthesize mpAdView;
@synthesize adWhirlView;
@synthesize adWhirlDelegate;
@synthesize adUnitID;

- (id)initWithAdUnitId:(NSString *)adUnitID_
   withAdwhirlDelegate:(id<AdWhirlDelegate>)delegate	
		forAdWhirlView:(AdWhirlView *)view
{
	if (self = [super init])
	{
		self.adUnitID = adUnitID_;
		self.adWhirlView = view;
		self.adWhirlDelegate = delegate;
	}
	return self;
}

+ (AdWhirlCustomEventAdapterMoPub *)requestMoPubAdForAdUnitID:(NSString *)adUnitID_
				       withAdWhirlDelegate:(id<AdWhirlDelegate>)delegate
							forAdWhirlView:(AdWhirlView *)view
{
	AdWhirlCustomEventAdapterMoPub *adapter = [[AdWhirlCustomEventAdapterMoPub alloc] initWithAdUnitId:adUnitID_ 
																				   withAdwhirlDelegate:delegate 
																						forAdWhirlView:view];
	[adapter getAd];
	return [adapter autorelease];
	
}

- (void)getAd{
	self.mpAdView = [[MPAdView alloc] initWithAdUnitId:self.adUnitID 
											 size:MOPUB_BANNER_SIZE];
	self.mpAdView.delegate = self;
	
	if ([adWhirlDelegate respondsToSelector:@selector(locationInfo)]){
		self.mpAdView.location = [adWhirlDelegate locationInfo];
	}
	
	self.mpAdView.keywords = [self mopubKeywords];
	[self.mpAdView loadAd];
	[adWhirlView replaceBannerViewWith:self.mpAdView];
	
}

// Overloads the keyword parameter used by mopub to include demographic info
- (NSString *)mopubKeywords{
	NSMutableArray *keywordArray = [[NSMutableArray alloc] init];
	if ([adWhirlDelegate respondsToSelector:@selector(keywords)]){
		[keywordArray addObject:[adWhirlDelegate keywords]];
	}	
	
	if ([adWhirlDelegate respondsToSelector:@selector(postalCode)]){
		[keywordArray addObject:[NSString stringWithFormat:@"m_postal:%@",
								 [adWhirlDelegate postalCode]]];
	}
	
	if ([adWhirlDelegate respondsToSelector:@selector(areaCode)]){
		[keywordArray addObject:[NSString stringWithFormat:@"m_area:%@",
								 [adWhirlDelegate areaCode]]];
	}
	if ([adWhirlDelegate respondsToSelector:@selector(dateOfBirth)]){
		
		NSDate *birth = [adWhirlDelegate dateOfBirth];

		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd"];
		
		[keywordArray addObject:[NSString stringWithFormat:@"m_dob:%@",
								 [dateFormat stringFromDate:birth]]];
		[keywordArray addObject:[NSString stringWithFormat:@"m_age:%i",
								 [self calculateAgeFromDateOfBirth:birth]]];
		[dateFormat release];
		
	}
	if ([adWhirlDelegate respondsToSelector:@selector(gender)]){
		[keywordArray addObject:[NSString stringWithFormat:@"m_gender:%@",
								 [adWhirlDelegate gender]]];
	}	
	if ([adWhirlDelegate respondsToSelector:@selector(searchString)]){
		[keywordArray addObject:[adWhirlDelegate searchString]];
	}	
	if ([adWhirlDelegate respondsToSelector:@selector(incomeLevel)]){
		[keywordArray addObject:[NSString stringWithFormat:@"m_income:%i",
								 [adWhirlDelegate incomeLevel]]];
	}	
	
	NSString *keywords = [keywordArray componentsJoinedByString:@","];
	
	[keywordArray release];
	
	return keywords;
}


- (void)rotateToOrientation:(UIInterfaceOrientation)orientation{
	[self.mpAdView rotateToOrientation:orientation];
}

- (void)dealloc{
	self.mpAdView.delegate = nil;
	[self.mpAdView release];
	[adWhirlView release];
	[adUnitID release];
	[super dealloc];
}

# pragma
# pragma MPAdViewDelegate
# pragma

- (UIViewController *)viewControllerForPresentingModalView{
	return [adWhirlDelegate viewControllerForPresentingModalView];
}

- (void)adViewDidLoadAd:(MPAdView *)adView{
	// MoPub ad sucessfully received
}

- (void)adViewDidFailToLoadAd:(MPAdView *)adView{
	[adWhirlView rollOver];
}

- (void)willPresentModalViewForAd:(MPAdView *)adView{
	adWhirlView.showingModalView = YES;
	if ([adWhirlDelegate respondsToSelector:@selector(adWhirlWillPresentFullScreenModal)]) {
		[adWhirlDelegate adWhirlWillPresentFullScreenModal];
	}
}

- (void)didDismissModalViewForAd:(MPAdView *)adView{
	if ([adWhirlDelegate respondsToSelector:@selector(adWhirlDidDismissFullScreenModal)]) {
		[adWhirlDelegate adWhirlDidDismissFullScreenModal];
	}
	adWhirlView.showingModalView = NO;
}
		 
# pragma
# pragma Helpers
# pragma
		 
 - (NSInteger)calculateAgeFromDateOfBirth:(NSDate *)birth {
	 if (birth == nil) {
		 return -1;
	 }
	 NSDate *today = [[NSDate alloc] init];
	 NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	 NSDateComponents *components = [gregorian components:NSYearCalendarUnit
												 fromDate:birth
												   toDate:today
												  options:0];
	 NSInteger years = [components year];
	 [gregorian release];
	 [today release];
	 return years;
 }
		 


@end
