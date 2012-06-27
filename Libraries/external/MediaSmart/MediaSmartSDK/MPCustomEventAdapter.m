//
//  MPCustomEventAdapter.m
//  MoPub
//
//  Created by Andrew He on 2/9/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPCustomEventAdapter.h"
#import "MPAdView.h"
#import "MPInterstitialAdController.h"
#import "MPLogging.h"

@implementation MPCustomEventAdapter

- (void)getAdWithParams:(NSDictionary *)params
{
	NSString *selectorString = [params objectForKey:@"X-Customselector"];
	if (!selectorString)
	{
		MPLogError(@"Custom event requested, but no custom selector was provided.",
			  selectorString);
		[self.delegate adapter:self didFailToLoadAdWithError:nil];
	}

	SEL selector = NSSelectorFromString(selectorString);
  NSObject *ad = [self.delegate adView];
	NSObject *delegate = [(MPAdView *)ad delegate];
  
  // Set the proper ad and delegate objects for the interstitial workflow 
  if ([delegate isKindOfClass:[MPInterstitialAdController class]]) {
    ad = delegate;
    delegate = [(MPInterstitialAdController *)delegate parent];
  }
	
	// First, try calling the no-object selector.
	if ([delegate respondsToSelector:selector])
	{
		[delegate performSelector:selector];
	}
	// Then, try calling the selector passing in the ad view.
	else 
	{
		NSString *selectorWithObjectString = [NSString stringWithFormat:@"%@:", selectorString];
		SEL selectorWithObject = NSSelectorFromString(selectorWithObjectString);
		
		if ([delegate respondsToSelector:selectorWithObject])
		{
			[delegate performSelector:selectorWithObject withObject:ad];
		}
		else
		{
			MPLogError(@"Ad view delegate does not implement custom event selectors %@ or %@.",
				  selectorString,
				  selectorWithObjectString);
			[self.delegate adapter:self didFailToLoadAdWithError:nil];
		}
	}

}

@end
