//
//  MPTimer.h
//  MoPub
//
//  Created by Andrew He on 3/8/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 
 * MPTimer is a simple wrapper class for NSTimer, adding pause/resume functionality.
 * It does not inherit NSTimer's entire interface -- just a few convenience methods for
 * creation and the -invalidate method.
 */
@interface MPTimer : NSObject 
{
	NSTimer *_timer;
	BOOL _isPaused;
	NSTimeInterval _secondsLeft;
	NSDate *_pauseDate;
}

+ (MPTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target 
						  selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats;
+ (MPTimer *)timerWithTimeInterval:(NSTimeInterval)seconds target:(id)target 
						  selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats;

- (BOOL)isValid;
- (void)invalidate;
- (BOOL)isScheduled;
- (BOOL)scheduleNow;
- (BOOL)pause;
- (BOOL)resume;

@end

/*
 * MPTimerTarget helps to avoid a common retain-cycle issue with NSTimer (and thus MPTimer). 
 * Specifically, MPAdView uses an MPTimer in order to pause/resume/invalidate appropriately. 
 * When MPAdView passes itself as the "target" to MPTimer's convenience method, the timer implicitly
 * retains the ad view, causing a cycle. Note that the problem still exists if MPAdView does not
 * retain MPTimer, since the run loop retains the timer as well.
 *
 * To avoid this, we pass an MPTimerTarget object as the "target" to MPTimer. When the timer fires,
 * MPTimerTarget posts a notification which MPAdView can observe. MPAdView retains both the timer 
 * and the target, but the timer no longer implicitly retains the ad view.
 */
@interface MPTimerTarget : NSObject
{
	NSString *_notificationName;
}

- (id)initWithNotificationName:(NSString *)name;

@end
