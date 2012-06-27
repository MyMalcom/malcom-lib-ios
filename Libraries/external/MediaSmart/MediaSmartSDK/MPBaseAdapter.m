//
//  MPBaseAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPBaseAdapter.h"
#import "MPLogging.h"

@implementation MPBaseAdapter

@synthesize delegate = _delegate;

- (id)initWithAdapterDelegate:(id<MPAdapterDelegate>)delegate
{
	if (self = [super init]) {
		_delegate = delegate;
	}
	return self;
}

- (void)dealloc
{
	[self unregisterDelegate];
	[super dealloc];
}

- (void)unregisterDelegate
{
	_delegate = nil;
}

- (void)getAd
{
	[self getAdWithParams:nil];
}

- (void)getAdWithParams:(NSDictionary *)params
{
	// To be implemented by subclasses.
	[self doesNotRecognizeSelector:_cmd];
}

- (void)_getAdWithParams:(NSDictionary *)params
{
  [self retain];
  [self getAdWithParams:params];
  [self release];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
	// Do nothing by default. Subclasses can override.
	MPLogDebug(@"rotateToOrientation %d called for adapter %@ (%p)",
		  newOrientation, NSStringFromClass([self class]), self);
}

@end
