//
//  MCMSplashViewController.m
//  malcommodule
//
//  Created by Alfonso Miranda Castro on 05/03/12.
//  Copyright (c) 2012 Mobivery. All rights reserved.
//

#import "MCMSplashViewController.h"
#import "MCMCore.h"
#import "MCMConfigManager.h"

@interface MCMSplashViewController (private)

- (void) createView;
- (void) finishDataLoading;

@end
@implementation MCMSplashViewController

@synthesize statusLabel = statusLabel_;
@synthesize imageView = imageView_;

- (void) viewDidLoad {
	[super viewDidLoad];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close) name:MCMCloseIntersitialNotification object:nil];
    
    [[MCMConfigManager sharedInstance] addObserver:self forKeyPath:@"updating" options:NSKeyValueObservingOptionNew context:nil];
    [[MCMConfigManager sharedInstance] addObserver:self forKeyPath:@"checkingVersion" options:NSKeyValueObservingOptionNew context:nil];
    [[MCMConfigSectionManager sharedInstance] addObserver:self forKeyPath:@"updating" options:NSKeyValueObservingOptionNew context:nil];
    [[MCMConfigSectionManager sharedInstance] addObserver:self forKeyPath:@"iconsDownloaded" options:NSKeyValueObservingOptionNew context:nil];
    
	//Regenerate view without animation
	if (showed_){
		[self createView];
	}
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
		
	[indicator_ release]; indicator_=nil;

}


- (void)dealloc {
	
	[indicator_ release]; indicator_=nil;
	
	//self.delegate=nil;
    
    [super dealloc];
}

#pragma mark Show/Hide methods

- (void) show {    
    if ([[NSThread currentThread] isMainThread]==NO){
        [self performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        return;
    }
    
	if (showed_) return;
	
	[self view];
	
	showed_=YES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
	//Create the view
	[self createView];
	
	//Animate to show
	CGRect frame = self.view.frame;
	//[self.view setFrame:CGRectMake(frame.origin.x, frame.origin.y+frame.size.height, frame.size.width, frame.size.height)];	
	//[UIView beginAnimations:nil context:nil];
	//[UIView setAnimationDuration:0.6];
	[self.view setFrame:frame];
	//[UIView commitAnimations];
	
    //Be sure that it still on top when finish animation and during all the web life  
    [self.view.superview performSelector:@selector(bringSubviewToFront:) withObject:self.view afterDelay:0.6];
    
	//Retain itself to avoid release while the view is showed (delegate objects are not retained)
	[self retain];
    
    int splashDelay = [[[MCMConfigManager sharedInstance] settingForKey:MCMConfigKeySplashDelay] intValue];
    
	NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:loadDate_];
	if (splashDelay>elapsedTime){
		[self performSelector:@selector(finishDataLoading) withObject:nil afterDelay:splashDelay-elapsedTime];
	}
	else {
		[self finishDataLoading];	 
	}
    
}

- (void) close {
    
    if ([[NSThread currentThread] isMainThread]==NO){
        [self performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:YES];
        return;
    }
    
	if (!showed_) return;
	
    
	//Animate to hide
	CGRect frame = self.view.frame;	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6];
	[self.view setFrame:CGRectMake(frame.origin.x, frame.origin.y+frame.size.height, frame.size.width, frame.size.height)];	
	[UIView commitAnimations];	
    
    showed_=NO;
    
	//Undo the retain operation done in show method
	[self release];
}

- (void) removeSplash {
    if ([[NSThread currentThread] isMainThread]==NO){
        [self performSelectorOnMainThread:@selector(removeSplash) withObject:nil waitUntilDone:YES];
        return;
    }
    
	if (self.view.superview==nil) return;
	
//	//Ask the delegate if it should disappear
//	if ([((NSObject *) delegate_) respondsToSelector:@selector(splashShouldDisappear:)]){
//		if ([delegate_ splashShouldDisappear:self]==NO)
//            return;
//	}
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	
	//Remove the splash screen
	[indicator_ stopAnimating];		
    
    
    //agarcia: Hack! BEGIN
    // if previously views were loaded, we have to remove and add again to the 
    // window in order to receive the orientation events properly
    
    UIWindow *wnd = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    NSArray *subviews = [wnd subviews];
    
    //If the splash is not in the first window, remove it
    NSInteger posSplash = [subviews indexOfObject:self.view];
    if (posSplash<0){
        [self.view removeFromSuperview];
        
    }
    //Else, remove all the siblings and insert them again without the splash
    else {
        //Swap views and remove and insert to propagate rotatios    
        for (UIView *view in subviews){
            [view removeFromSuperview];
        }
        
        for (UIView *view in subviews){
            if (view!=self.view)
                [wnd addSubview:view];
        }
    }
    //agarcia: Hack END
    
    
	//[self.view removeFromSuperview];		
}

#pragma mark Private methods

- (void) refreshStatus {
	
	//If the Config manager is updating, we show it
	if ([[MCMConfigManager sharedInstance] updating]){
		[indicator_ startAnimating];
		[statusLabel_ setText:NSLocalizedString(@"Updating configuration file",@"")];
		return;
	}	
    
	//If the user is being prompt with a version alert
	if ([[MCMConfigManager sharedInstance] checkingVersion]){
		[indicator_ startAnimating];
		[statusLabel_ setText:NSLocalizedString(@"Checking the application version",@"")];
		return;
	}
    
	//If Config Section manager is updating, we show it
	if ([[MCMConfigSectionManager sharedInstance] updating]){
		[indicator_ startAnimating];
		[statusLabel_ setText:NSLocalizedString(@"Updating sections",@"")];
		return;
	}
    
    //If Config Section manager is downloading icons, we show it
	if (([[MCMConfigSectionManager sharedInstance] loaded]==YES) &&
        ([[MCMConfigSectionManager sharedInstance] iconsDownloaded]==NO) && ([[MCMConfigSectionManager sharedInstance] error]==NO) && ([[MCMConfigManager sharedInstance] error]==NO)){
		[indicator_ startAnimating];
		[statusLabel_ setText:NSLocalizedString(@"Downloading icons",@"")];
		return;
	}
	
	[statusLabel_ setText:NSLocalizedString(@"Waiting",@"")];
	int splashDelay = [[[MCMConfigManager sharedInstance] settingForKey:MCMConfigKeySplashDelay] intValue];
	NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:loadDate_];
	if (splashDelay>elapsedTime){
		[self performSelector:@selector(finishDataLoading) withObject:nil afterDelay:splashDelay-elapsedTime];
	}
	else {
		[self finishDataLoading];	 
	}
}

- (void) createView {
	
	//Add the view to the window if no parent specified
	if (self.view.superview==nil){
        
        UIView *parentView = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        CGRect wndFrame = [parentView frame];
        CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
        self.view.frame=CGRectMake(0, statusFrame.size.height, wndFrame.size.width, wndFrame.size.height-statusFrame.size.height);
		[parentView addSubview:self.view];
	}
	else {
		[self.view setFrame:CGRectMake(0, 0, self.view.superview.frame.size.width, self.view.superview.frame.size.height)];
	}
    
	[self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    loadDate_ = [[NSDate date] retain];
    
//    UIImageView *splashImage = [[UIImageView alloc] initWithImage:[[MCMConfigManager sharedInstance] splashImage]];
//    [splashImage setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
//    [splashImage setContentMode:UIViewContentModeScaleAspectFill];
//    [self.view addSubview:splashImage];
//    [splashImage release];
    
    if (self.imageView==nil){
        
        UIImageView *splashImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [splashImage setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [splashImage setContentMode:UIViewContentModeScaleAspectFill];
		[self.view addSubview:splashImage];
		self.imageView=splashImage;
		[splashImage release];
        
	}
	
    if (self.statusLabel==nil){
		int posX=self.view.frame.size.width/4;
		int width=self.view.frame.size.width/2;
		int posY=self.view.frame.size.height*3/4;
		int height=self.view.frame.size.height/8;
		UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
		[statusLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|
         UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|
         UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
		[statusLabel setNumberOfLines:0];
		[statusLabel setTextAlignment:UITextAlignmentCenter];
		[statusLabel setBackgroundColor:[UIColor clearColor]];
		[statusLabel setTextColor:[UIColor grayColor]];
		[self.view addSubview:statusLabel];		
		self.statusLabel=statusLabel;
		[statusLabel release];
	}
	
	//Check if the indicator is already allocated
	if (indicator_==nil){
		indicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[indicator_ setFrame:CGRectMake((self.view.frame.size.width-indicator_.frame.size.width)/2, 
										(self.view.frame.size.height-indicator_.frame.size.height)/2,
										indicator_.frame.size.width,
										indicator_.frame.size.height)];
		[indicator_ setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
		 UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
		[indicator_ setHidesWhenStopped:YES];
		[self.view addSubview:indicator_];
	}
	
	[indicator_ startAnimating];
    
    //Load the splash image
    
	[self.imageView setImage:[[MCMConfigManager sharedInstance] splashImage]];
	
	[self refreshStatus];
    
    //Bring to the top
    [self.view.superview performSelector:@selector(bringSubviewToFront:) withObject:self.view afterDelay:0];
    
}

- (void) finishDataLoading {
    
    //Data already loaded
    [self willChangeValueForKey:@"dataLoaded"];
    //dataLoaded_=YES;
    [self didChangeValueForKey:@"dataLoaded"];
    
    [self removeSplash];
    
}

#pragma mark KeyValue Observing methods

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{	
	[self performSelectorOnMainThread:@selector(refreshStatus) withObject:nil waitUntilDone:NO];
}

@end
