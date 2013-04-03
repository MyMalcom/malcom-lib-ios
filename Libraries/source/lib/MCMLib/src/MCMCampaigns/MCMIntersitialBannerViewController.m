//
//  MCMIntersitialBannerViewController.m
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 24/01/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MCMIntersitialBannerViewController.h"
#import "MCMCoreUtils.h"



#define bannerHeight 55.0
#define offset 20.0
#define statusBarOffset 20.0
#define lateralOffsets 10.0

#define middleLandscapeWidth 350.0f
#define middleLandscapeHeight 200.0f
#define middlePortraitWidth 240.0f
#define middlePortraitHeight 350.0f

@interface MCMIntersitialBannerViewController (private)
-(void)configureView;
@end

@implementation MCMIntersitialBannerViewController

@synthesize currentCampaignModel = _currentCampaignModel;
@synthesize containerView = _containerView;
@synthesize appstoreContainerView = _appstoreContainerView;

- (id)initInView:(UIView *)view andCampaign:(MCMCampaignModel*)campaign
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.containerView = view;
        self.currentCampaignModel = campaign;
    }
    return self;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self configureView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Public methods


/**
 Method that returns if the banner needs to be shown on the main window or in another specified view.
 @param BOOL Yes if it needs to be displayed on the main window and Not if in a specified view.
 @since 2.0.0
 */
-(BOOL)needsToDisplayOnWindow{
    
    //in case the type is TOP or BOTTOM it will be shown in the specified view
    if ([self.currentCampaignModel.position isEqualToString:TOP] || [self.currentCampaignModel.position isEqualToString:BOTTOM]) {
        return NO;
    }else{ //otherwise it needs to be displayed on the window on the top of everyview (navbars, tabbars..)
        return YES;
    }
}


#pragma mark - privated methods

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification
{
    /*
     This notification is most likely triggered inside an animation block,
     therefore no animation is needed to perform this nice transition.
     */
    if([self.currentCampaignModel.position isEqualToString:MIDDLE_LANDSCAPE]||[self.currentCampaignModel.position isEqualToString:MIDDLE_PORTRAIT]){
//        [self rotateAccordingToStatusBarOrientationAndSupportedOrientations]; //use this method if you want to rotate everything
        
        [self close];
    }

}

// problem: it loses the button responses once is rotated :( 
//- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations
//{
//
//    CGRect frameScreen = [MCMCoreUtils rectForViewScreen];
//    CGPoint center = CGPointMake(frameScreen.size.width/2.0, frameScreen.size.height/2.0);
//
//    NSLog(@">> before: %@ ",NSStringFromCGRect(self.view.frame));
//    [self.view setFrame:frameScreen];
//    NSLog(@">> after: %@",NSStringFromCGRect(self.view.frame));
//    
//    [self.backgroundFadedView setFrame:frameScreen];
//    
//    self.bannerButton.center = center;
//    self.bannerButton.layer.frame = self.bannerButton.frame;
//    
//}
//


/**
 Method that closes the banner and calls the delegate
 @since 2.0.0
 */
- (void)close {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.delegate mediaClosed];
}


/**
 Method that opens the appstore inside the app or in another web view depending on the iOS version. As well, sends the campaignHit click event.
 @since 2.0.0
 */
- (void)openURLAppstore {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CAMPAINGHIT" object:@"CLICK"];
    
    if(NSClassFromString(@"SKStoreProductViewController")) { // Checks for iOS 6 feature.
        
        SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
        storeController.delegate = self; // productViewControllerDidFinish
        
        // Example app_store_id (e.g. for Words With Friends)
        // [NSNumber numberWithInt:581665873];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * idApple = [f numberFromString:self.currentCampaignModel.urlAppStore];
        [f release];
        NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : idApple };
        
        
        [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
            if (result) {
			//if it doesnt have where to place the appstoreView it will place it on the VC handler of the banner container view
                if(!_appstoreContainerView){
                    id rootVC = [self.containerView nextResponder];
                    [rootVC presentViewController:storeController animated:YES completion:nil];
                }else{ //if it is specified, it will be placed on the appstoreContainerView 
                    [[_appstoreContainerView nextResponder] presentViewController:storeController animated:YES completion:nil];

                }
                
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"There was a problem displaying the app" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        }];
        
        
    } else { // Before iOS 6, we can only open the URL
              
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/es/app/id%@", self.currentCampaignModel.urlAppStore]]];
        
    }
    
    if ([self needsToDisplayOnWindow]) {
        [self close];
    }
}

/**
 Method that configures the view requesting firstly the image to show in the banner.
 @since 2.0.0
 */
-(void)configureView{

    //hides the view while is getting the media image
    [self.view setHidden:YES];
    
    NSURL *url = [NSURL URLWithString:self.currentCampaignModel.media];
    
    //launches the new connection asynchronously
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:20.0];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:[self retain]];

}


/**
 Method that once it has the image in the memory it will be displayed on screen.
 @since 2.0.0
 */
-(void)showImage{
    
    CGRect frameScreen = [MCMCoreUtils rectForViewScreen];
    CGRect frame = [MCMCoreUtils rectForViewScreen];
    CGPoint center = CGPointMake(frameScreen.size.width/2.0, frameScreen.size.height/2.0);
    
    //reframes the size of the view
    if ([self.currentCampaignModel.position isEqualToString:TOP]) { //top case
        
        int yOffset = 0;
        //if the status bar is visible
        if ([UIApplication sharedApplication].statusBarHidden == NO){
            yOffset = statusBarOffset;
        }
        
        frame = CGRectMake(0, 0, self.containerView.frame.size.width, bannerHeight);
    }
    else if ([self.currentCampaignModel.position isEqualToString:BOTTOM]) { //bottom case
        
        frame = CGRectMake(0, self.containerView.frame.size.height - bannerHeight, self.containerView.frame.size.width, bannerHeight);
        
    }
    
    //sets the color and the new frame
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    NSLog(@">> before: %@ ",NSStringFromCGRect(self.view.frame));
    [self.view setFrame:frame];
    NSLog(@">> after: %@",NSStringFromCGRect(self.view.frame));

    
    
    //just in case the campaign is middle or fullscreen
    if([self.currentCampaignModel.position isEqualToString:MIDDLE_LANDSCAPE] || [self.currentCampaignModel.position isEqualToString:MIDDLE_PORTRAIT] || [self.currentCampaignModel.position isEqualToString:FULLSCREEN]){
        
        //creates the backgroundView
        self.backgroundFadedView = [[UIView alloc] initWithFrame:[MCMCoreUtils rectForViewScreen]];
        [self.backgroundFadedView setBackgroundColor:[UIColor blackColor]];
        [self.backgroundFadedView setAlpha:0.7];
        [self.view addSubview:self.backgroundFadedView];
        
    }
    
    
    
    //creates the button that is going to be the pushable
    self.bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bannerButton setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.bannerButton setBackgroundColor:[UIColor clearColor]];
    

    
    //in case it is a "middle" it needs to be centered and add a background view with alpha 0.7
    if ([self.currentCampaignModel.position isEqualToString:MIDDLE_LANDSCAPE] || [self.currentCampaignModel.position isEqualToString:MIDDLE_PORTRAIT]) {
       
        int width;
        int height;

        if([self.currentCampaignModel.position isEqualToString:MIDDLE_LANDSCAPE]){
            width = middleLandscapeWidth;
            height = middleLandscapeHeight;
        }else if([self.currentCampaignModel.position isEqualToString:MIDDLE_PORTRAIT]){
            width = middlePortraitWidth;
            height = middlePortraitHeight;
        }
        
        //centers the bannerButton
        [self.bannerButton setFrame:CGRectMake(0, 0, width, height)];
        self.bannerButton.center = center;
        
        //sets it a border 

        [self.bannerButton.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.bannerButton.layer setShadowOpacity:0.8];
        [self.bannerButton.layer setShadowRadius:3.0];
        [self.bannerButton.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        
        //creates the backgroundView of the button in order to provide it the border layer
        UIView *auxView = [[UIView alloc] initWithFrame:self.bannerButton.bounds];
        [auxView setBackgroundColor:[UIColor clearColor]];
        [auxView setAlpha:1];
        [auxView setUserInteractionEnabled:NO];
        [self.bannerButton addSubview:auxView];
        [self.bannerButton sendSubviewToBack:auxView];        
        [auxView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [auxView.layer setBorderWidth:3.0f];

    }

    
    //sets the image with the data media retrieved
    UIImage *image = [UIImage imageWithData:self.dataMedia];
    [self.bannerButton setImage:image forState:UIControlStateNormal];
    [self.bannerButton addTarget:self action:@selector(openURLAppstore) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.bannerButton setBackgroundColor:[UIColor blackColor]];

    [self.view addSubview:self.bannerButton];
    
    //unhides the view
    [self.view setHidden:NO];
    
    if([self.currentCampaignModel.position isEqualToString:MIDDLE_LANDSCAPE] || [self.currentCampaignModel.position isEqualToString:MIDDLE_PORTRAIT] || [self.currentCampaignModel.position isEqualToString:FULLSCREEN]){
        
        int yOffset = 0;
        //if the status bar is visible
        if ([UIApplication sharedApplication].statusBarHidden == NO){
            yOffset = statusBarOffset;
        }
        
        self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-45, 10+yOffset, 30, 30)];
        [self.closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self.closeButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
        [self.closeButton setBackgroundColor:[UIColor blackColor]];
        [self.closeButton setTitle:@"X" forState:UIControlStateNormal];
        [self.closeButton.titleLabel setTextColor:[UIColor whiteColor]];
        [self.closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [self.closeButton.layer setCornerRadius:14.0f];
        [self.closeButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.closeButton.layer setBorderWidth:1.5f];
        [self.closeButton.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.closeButton.layer setShadowOpacity:0.8];
        [self.closeButton.layer setShadowRadius:3.0];
        [self.closeButton.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        [self.bannerButton addSubview:self.closeButton];
        [self.bannerButton setClipsToBounds:NO];
        [self.closeButton release];
        
        
        CGRect auxFrame = self.closeButton.frame;
        
        //sets the position of the X button in case it is MIDDLE LANDSCAPE OR PORTRAIT in the top right corner
        if([self.currentCampaignModel.position isEqualToString:MIDDLE_LANDSCAPE]||[self.currentCampaignModel.position isEqualToString:MIDDLE_PORTRAIT]){
            
            auxFrame.origin.x =  self.bannerButton.frame.size.width - self.closeButton.frame.size.width/2;
            auxFrame.origin.y =  - self.closeButton.frame.size.height/2;
            
            self.closeButton.frame = auxFrame;
        }
        
    
    }
    
    
    //Be sure that it still on top when finish animation and during all the web life
    [self.view.superview performSelector:@selector(bringSubviewToFront:) withObject:self.view];

    
}




#pragma mark - SKStoreProductViewControllerDelegate methods

// Sent if the user requests that the page be dismissed
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    
    [viewController dismissModalViewControllerAnimated:YES];
    
    //[self configureView];
}

#pragma mark - Connections delegate methods

-(void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    
    if (self.dataMedia==nil) {
		self.dataMedia = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [self.dataMedia appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {

    //when connection is finished and self.dataMedia is not nill
    if(self.dataMedia != nil){
        [self showImage];	 //shows the image
        
        //calls the delegate to advise that the image is loaded.
        [self.delegate mediaFinishLoading];
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
	self.dataMedia = nil;
    
    //calls the delegate telling that the loading failed
    [self.delegate mediaFailedLoading];
	
}


@end
