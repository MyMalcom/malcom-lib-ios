//
//  MCMCoreWebAlertView.m
//

#import <QuartzCore/QuartzCore.h>

#import "MCMCoreWebAlertView.h"
#import "MCMCore.h"

@interface MCMCoreWebAlertView (private)

- (void) createView;

@end

@implementation MCMCoreWebAlertView

@synthesize url=url_, delegate=delegate_, isBanner = isBanner_, htmlString = htmlString_;


- (void) viewDidLoad {
	[super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close) name:MCMCloseIntersitialNotification object:nil];
    isBanner_ = NO;
	//Regenerate view without animation
	if (showed_){
		[self createView];
	}
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
	[webView_ setDelegate:nil];
	[webView_ stopLoading];
	[webView_ release]; webView_=nil;
	
	[closeButton_ release]; closeButton_=nil;	
	[indicator_ release]; indicator_=nil;
    
    isBanner_ = NO;
}


- (void)dealloc {
	[webView_ setDelegate:nil];
	[webView_ stopLoading];
	[webView_ release]; webView_=nil;
	
	[closeButton_ release]; closeButton_=nil;	
	[indicator_ release]; indicator_=nil;
	
	self.delegate=nil;
	self.url=nil;
	
    
    [super dealloc];
}

#pragma mark Show/Hide methods

- (void) show{
    
    if ([[NSThread currentThread] isMainThread]==NO){
        [self performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        return;
    }
    
	if (showed_) return;
	
	[self view];
	
	showed_=YES;
		
    //statusHidden_ = [[UIApplication sharedApplication] isStatusBarHidden];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
	//Create the view
	[self createView];
	
	//Animate to show
	CGRect frame = self.view.frame;
	[self.view setFrame:CGRectMake(frame.origin.x, frame.origin.y+frame.size.height, frame.size.width, frame.size.height)];	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6];
	[self.view setFrame:frame];
	[UIView commitAnimations];
	
    //Be sure that it still on top when finish animation and during all the web life  
    [self.view.superview performSelector:@selector(bringSubviewToFront:) withObject:self.view afterDelay:0.6];

	//Retain itself to avoid release while the view is showed (delegate objects are not retained)
	[self retain];
}

- (void) close{
    
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

	//Notify the delegate
	if ([((NSObject *)delegate_) respondsToSelector:@selector(webAlertClose:)]){
		[delegate_ webAlertClose:self];
	}
    
    
    //[[UIApplication sharedApplication] setStatusBarHidden:statusHidden_ withAnimation:UIStatusBarAnimationSlide];
    showed_=NO;
    
	//Undo the retain operation done in show method
	[self release];
}


#pragma mark Private methods
- (void) createView {
	if (url_==nil) return;
	
	
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
	
	//Check if the webview is already allocated
	if (webView_==nil){
		webView_ = [[UIWebView alloc] initWithFrame:self.view.bounds];
		[webView_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
		[webView_ setDelegate:self];
		[self.view addSubview:webView_];
	}
	
	//Check if the close button is already allocated
	if (closeButton_==nil){
		closeButton_ = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-45, 10, 35, 35)];
		[closeButton_ addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
		[closeButton_ setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
		[closeButton_ setBackgroundColor:[UIColor blackColor]];
		[closeButton_ setTitle:@"X" forState:UIControlStateNormal];
		[closeButton_.titleLabel setTextColor:[UIColor whiteColor]];
		[closeButton_.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
		[self.view addSubview:closeButton_];
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
	
	//Load the webview
    
    if (isBanner_) {
        
        [webView_ loadHTMLString:htmlString_ baseURL:nil];
        
    }
    else {
	
        [webView_ loadRequest:[NSURLRequest requestWithURL:url_]];
        
    }
    
	[indicator_ startAnimating];
    
    //Bring to the top
    self.view.layer.zPosition=100;
    [self.view.superview performSelector:@selector(bringSubviewToFront:) withObject:self.view afterDelay:0];
    
}

#pragma mark UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[indicator_ stopAnimating];	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	[indicator_ stopAnimating];	
}

@end
