    //
//  MCMConfigSplashViewController.m
//

#import <QuartzCore/QuartzCore.h>

#import "MCMConfigSplashViewController.h"
#import "MCMConfig.h"
#import "MCMConfigDefines.h"
#import "MCMLog.h"

@interface MCMConfigSplashViewController (private)

- (void) refreshStatus;
- (void) finishDataLoading;

@end

@implementation MCMConfigSplashViewController

@synthesize imageView=imageView_, statusLabel = statusLabel_, indicator=indicator_, delegate=delegate_, dataLoaded=dataLoaded_;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {		
		dataLoaded_=NO;
        
		//Check if the MCMConfigManager is already loaded, or load from cache if not
		if ([[MCMConfigManager sharedInstance] loaded]==NO){
            
            [MCMLog log:[NSString stringWithFormat:@"Malcom Config - MCMConfigSplashManager should be loaded before creating the splash Screen"] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
			[[MCMConfigManager sharedInstance] loadSettingsWithConfigUrl:nil];
		}
		
		[[MCMConfigManager sharedInstance] addObserver:self forKeyPath:@"updating" options:NSKeyValueObservingOptionNew context:nil];
		[[MCMConfigManager sharedInstance] addObserver:self forKeyPath:@"checkingVersion" options:NSKeyValueObservingOptionNew context:nil];
        [[MCMConfigSectionManager sharedInstance] addObserver:self forKeyPath:@"updating" options:NSKeyValueObservingOptionNew context:nil];
        [[MCMConfigSectionManager sharedInstance] addObserver:self forKeyPath:@"iconsDownloaded" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.layer.zPosition=kSplashZIndex;

	loadDate_ = [[NSDate date] retain];
	
	//If no imageView set, we create one
	if (self.imageView==nil){
        
        UIImageView *splashImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [splashImage setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [splashImage setContentMode:UIViewContentModeScaleAspectFill];
		[self.view addSubview:splashImage];
		self.imageView=splashImage;
		[splashImage release];
        
	}
	
	//If no status label set, we create one
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
	
	//If no status label set, we create one
	if (self.indicator==nil){
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];		
		int posX=(self.view.frame.size.width-indicator.frame.size.width)/2;
		int posY=(self.statusLabel.frame.origin.y-indicator.frame.size.height);
		[indicator setFrame:CGRectMake(posX, posY, indicator.frame.size.width, indicator.frame.size.height)];
		[indicator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|
										UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
		[indicator setHidesWhenStopped:YES];
		[self.view addSubview:indicator];
		self.indicator=indicator;
		[indicator release];
	}
		
	//Load the splash image
	[self.imageView setImage:[[MCMConfigManager sharedInstance] splashImage]];
	
	[self refreshStatus];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[loadDate_ release]; loadDate_=nil;
	
    // Release any retained subviews of the main view.    
	self.imageView=nil;
	self.indicator=nil;
	self.statusLabel=nil;	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //Get supported orientations
    NSArray *orientations = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
    
    for (NSString *orientation in orientations){
        if (([orientation isEqualToString:@"UIInterfaceOrientationPortrait"]) && (interfaceOrientation==UIInterfaceOrientationPortrait))
            return YES;
        
        if (([orientation isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"]) && (interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
            return YES;

        if (([orientation isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) && (interfaceOrientation==UIInterfaceOrientationLandscapeLeft))
            return YES;
        
        if (([orientation isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) && (interfaceOrientation==UIInterfaceOrientationLandscapeRight))
            return YES;
    }
	return NO;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.imageView setImage:[[MCMConfigManager sharedInstance] splashImageForOrientation:toInterfaceOrientation]];
}

- (void)dealloc {
	self.imageView=nil;
	self.indicator=nil;
	self.statusLabel=nil;
	[loadDate_ release]; loadDate_=nil;
	
	[[MCMConfigManager sharedInstance] removeObserver:self forKeyPath:@"updating"];
	[[MCMConfigManager sharedInstance] removeObserver:self forKeyPath:@"checkingVersion"];
	[[MCMConfigSectionManager sharedInstance] removeObserver:self forKeyPath:@"updating"];
    [[MCMConfigSectionManager sharedInstance] removeObserver:self forKeyPath:@"iconsDownloaded"];    
    
    [super dealloc];
}

- (void) removeSplash {
    if ([[NSThread currentThread] isMainThread]==NO){
        [self performSelectorOnMainThread:@selector(removeSplash) withObject:nil waitUntilDone:YES];
        return;
    }
    
	if (self.view.superview==nil) return;
	
	//Ask the delegate if it should disappear
	if ([((NSObject *) delegate_) respondsToSelector:@selector(splashShouldDisappear:)]){
		if ([delegate_ splashShouldDisappear:self]==NO)
            return;
	}
	
	//Remove the splash screen
	[indicator_ stopAnimating];		
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
        
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
    }
    else {
        
        [self.view removeFromSuperview];	
        
    }
}

#pragma mark ----
#pragma mark  Private methods
#pragma mark ----


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

- (void) finishDataLoading{

    //Data already loaded
    [self willChangeValueForKey:@"dataLoaded"];
    dataLoaded_=YES;
    [self didChangeValueForKey:@"dataLoaded"];
    
    [self removeSplash];
    
    //Charged Intersitial, if exist
    
//    NSLog(@"___________________Charged Intersitial, if exist");
//    
//    NSURL *url = [NSURL URLWithString:[[MCMConfigManager sharedInstance] settingForKey:MCMInterstitialWeb]];
//    
//    if (url){
//        
//        id alert = [[MCMCoreWebAlertView alloc] init];
//        [((MCMCoreWebAlertView *) alert) setUrl:url];
//        [alert setDelegate:self];
//        
//        [alert show];
//        
//    }

    
}

#pragma mark KeyValue Observing methods

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{	
	[self performSelectorOnMainThread:@selector(refreshStatus) withObject:nil waitUntilDone:NO];
}

@end
