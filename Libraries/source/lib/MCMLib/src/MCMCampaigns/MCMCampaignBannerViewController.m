//
//  MCMIntersitialBannerViewController.m
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 24/01/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MCMCampaignBannerViewController.h"
#import "MCMCore.h"
#import "MCMCampaignsHelper.h"

#define bannerHeight 55.0
#define offset 20.0
#define statusBarOffset 20.0
#define lateralOffsets 10.0

#define middleLandscapeWidth 350.0f
#define middleLandscapeHeight 200.0f
#define middlePortraitWidth 240.0f
#define middlePortraitHeight 350.0f

#define middleLandscapeIPadWidth 750.0f
#define middleLandscapeIPadHeight 560.0f
#define middlePortraitIPadWidth 560.0f
#define middlePortraitIPadHeight 750.0f

#ifdef UI_USER_INTERFACE_IDIOM()
    #define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
    #define IS_IPAD() (false)
#endif


@interface MCMCampaignBannerViewController ()

@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UIView *backgroundFadedView;      //faded view for middle banners
@property (nonatomic, retain) UIButton *closeButton;            //button to close the campaign
@property (nonatomic, retain) UIButton *bannerButton;           //button with campaign
@property (nonatomic, retain) NSMutableData *dataMedia;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) UIImage *placeHolderImage;        //Image to show while the banner is loading

- (void)close;
- (void)configureView;

/**
 Method that perform the action when the banner is pressed.
 @since 2.0.0
 */
- (void)bannerPressed;

/**
 Method that opens the appstore inside the app or in another web view depending on the iOS version. As well, sends the campaignHit click event.
 @since 2.0.0
 */
- (void)openURLAppstore;

/**
 Method that once it has the image in the memory it will be displayed on screen.
 @since 2.0.0
 */
- (void)showBannerWithPlaceholder:(UIImage *)placeholder;

/**
 Method that opens the external url. As well, sends the campaignHit click event.
 @since 2.0.6
 */
- (void)openExternalURL;

@end

@implementation MCMCampaignBannerViewController

@synthesize currentCampaignDTO = _currentCampaignModel;
@synthesize containerView;
@synthesize appstoreContainerView;
@synthesize backgroundFadedView;
@synthesize closeButton;
@synthesize bannerButton;
@synthesize dataMedia;
@synthesize connection;
@synthesize placeHolderImage;

- (id)initInView:(UIView *)view withPlaceholder:(UIImage *)placeHolder andCampaign:(MCMCampaignDTO*)campaign
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.containerView = view;
        self.placeHolderImage = placeHolder;
        self.currentCampaignDTO = campaign;
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

- (void)viewWillAppear:(BOOL)animated {
    
    [self configureView];
}

#pragma mark - Public methods

- (void)showCampaignBannerAnimated {
    
    [self.view setAlpha:0.0f];
    
    //depending on the type of position it will show a bouncing animation
    if((self.currentCampaignDTO.position == MIDDLE_LANDSCAPE) ||
       (self.currentCampaignDTO.position == MIDDLE_PORTRAIT)){
        
        
        [self.bannerButton setTransform:CGAffineTransformMakeScale(0.1, 0.1)];
        [self.backgroundFadedView setAlpha:0.0f];
        [self.closeButton setAlpha:0.0f];
        
        [UIView animateWithDuration: 0.3
                         animations: ^{
                             self.bannerButton.transform = CGAffineTransformMakeScale(1.2, 1.2);
                             [self.view setAlpha:1.0f];
                             [self.backgroundFadedView setAlpha:0.7f];
                             
                         }
                         completion: ^(BOOL finished){
                             [UIView animateWithDuration:1.0/10.0
                                              animations: ^{
                                                  self.bannerButton.transform = CGAffineTransformMakeScale(0.9, 0.9);
                                              }
                                              completion: ^(BOOL finished){
                                                  [UIView animateWithDuration:1.0/5.0
                                                                   animations: ^{
                                                                       self.bannerButton.transform = CGAffineTransformIdentity;
                                                                       [self.closeButton setAlpha:1.0f];
                                                                       
                                                                   }completion:^(BOOL finished) {
                                                                   }];
                                              }];
                         }];
        
        
    }else{ //or a simple animation of fade in
        
        [UIView animateWithDuration: 0.3 animations: ^{
            [self.view setAlpha:1.0f];
        }
                         completion: ^(BOOL finished){}];
    }
    
}

/**
 Method that returns if the banner needs to be shown on the main window or in another specified view.
 @param BOOL Yes if it needs to be displayed on the main window and Not if in a specified view.
 @since 2.0.0
 */
- (BOOL)needsToDisplayOnWindow{
    
    return [self.currentCampaignDTO showOnWindow];
}

#pragma mark - privated methods

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification
{
    /*
     This notification is most likely triggered inside an animation block,
     therefore no animation is needed to perform this nice transition.
     */
    if((self.currentCampaignDTO.position == MIDDLE_LANDSCAPE)||(self.currentCampaignDTO.position == MIDDLE_PORTRAIT)){        
        [self close];
    }
    
}


/**
 Method that closes the banner and calls the delegate
 @since 2.0.0
 */
- (void)close{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaClosed)]){
        [self.delegate mediaClosed];
    }
}

- (void)bannerPressed{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerPressed:)]) {
        [self.delegate bannerPressed:self.currentCampaignDTO];
    }
    
    if (self.currentCampaignDTO.type == IN_APP_CROSS_SELLING) {
        
		MCMLog(@"IN_APP_CROSS_SELLING banner pressed");
        
        [self openURLAppstore];
        
    } else if (self.currentCampaignDTO.type == IN_APP_PROMOTION) {
		
        MCMLog(@"IN_APP_PROMOTION banner pressed");
		
    } else if (self.currentCampaignDTO.type == IN_APP_EXTERNAL_URL) {
		
        MCMLog(@"IN_APP_EXTERNAL_URL banner pressed");
        
        [self openExternalURL];
    }
    
    [MCMCampaignsHelper notifyServer:kCampaignClickHit andCampaign:self.currentCampaignDTO];
    
}


/**
 Method that opens the appstore inside the app or in another web view depending on the iOS version. As well, sends the campaignHit click event.
 @since 2.0.0
 */
- (void)openURLAppstore{
    
    [MCMCampaignsHelper openAppStoreWithAppId:self.currentCampaignDTO.promotionIdentifier withDelegate:self andAppStoreContainerView:self.appstoreContainerView];
    
    if ([self.currentCampaignDTO showOnWindow]) {
        [self close];
    }
}

/**
 Method that configures the view requesting firstly the image to show in the banner.
 @since 2.0.0
 */
- (void)configureView{
    
    //hides the view while is getting the media image
    [self.view setHidden:YES];
    
    NSURL *url = [NSURL URLWithString:self.currentCampaignDTO.media];
    
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
- (void)showBannerWithPlaceholder:(UIImage *)placeholder{
    
    CGRect frameScreen = [MCMCoreUtils rectForViewScreen];
    CGRect frame = [MCMCoreUtils rectForViewScreen];
    CGPoint center = CGPointMake(frameScreen.size.width/2.0, frameScreen.size.height/2.0);
    
    //reframes the size of the view
    if (![self.currentCampaignDTO showOnWindow]) {
        CGRect newFrame = [[self.view superview] frame];
        newFrame.origin = CGPointMake(0, 0);
        frame = newFrame;
    }
    
    //sets the color and the new frame
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self.view setFrame:frame];
    
    //just in case the campaign is middle or fullscreen
    if([self.currentCampaignDTO showOnWindow]){
        
        //creates the backgroundView
        self.backgroundFadedView = [[UIView alloc] initWithFrame:[MCMCoreUtils rectForViewScreen]];
        [self.backgroundFadedView setBackgroundColor:[UIColor blackColor]];
        [self.backgroundFadedView setAlpha:0.7];
        [self.view addSubview:self.backgroundFadedView];
        
    }
    
    //creates the button that is going to be the pushable
    self.bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bannerButton setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    //in case it is a "middle" it needs to be centered and add a background view with alpha 0.7
    if ((self.currentCampaignDTO.position == MIDDLE_LANDSCAPE) || (self.currentCampaignDTO.position == MIDDLE_PORTRAIT)) {
        
        int width = 0;
        int height = 0;
        
        if(self.currentCampaignDTO.position == MIDDLE_LANDSCAPE && !IS_IPAD()){
            width = middleLandscapeWidth;
            height = middleLandscapeHeight;
        }else if(self.currentCampaignDTO.position == MIDDLE_PORTRAIT && !IS_IPAD()){
            width = middlePortraitWidth;
            height = middlePortraitHeight;
        }
        else if(self.currentCampaignDTO.position == MIDDLE_LANDSCAPE && IS_IPAD()){
            width = middleLandscapeIPadWidth;
            height = middleLandscapeIPadHeight;
        }else if(self.currentCampaignDTO.position == MIDDLE_PORTRAIT && IS_IPAD()){
            width = middlePortraitIPadWidth;
            height = middlePortraitIPadHeight;
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
    [self.bannerButton addTarget:self action:@selector(bannerPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.bannerButton setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:self.bannerButton];
    
    //unhides the view
    [self.view setHidden:NO];
    
    if([self.currentCampaignDTO showOnWindow]){
        
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
        if((self.currentCampaignDTO.position == MIDDLE_LANDSCAPE)||(self.currentCampaignDTO.position == MIDDLE_PORTRAIT)){
            
            auxFrame.origin.x =  self.bannerButton.frame.size.width - self.closeButton.frame.size.width/2;
            auxFrame.origin.y =  - self.closeButton.frame.size.height/2;
            
            self.closeButton.frame = auxFrame;
        }
        
    }
    
    //Be sure that it still on top when finish animation and during all the web life
    [self.view.superview performSelector:@selector(bringSubviewToFront:) withObject:self.view];
    
}

/**
 Method that opens the external url. As well, sends the campaignHit click event.
 @since 2.0.6
 */
- (void)openExternalURL {
	
	[MCMCampaignsHelper openExternalCampaign:self.currentCampaignDTO];
	
	if ([self.currentCampaignDTO showOnWindow]) {
        [self close];
    }
	
}

#pragma mark - SKStoreProductViewControllerDelegate methods

// Sent if the user requests that the page be dismissed
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
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
        [self showBannerWithPlaceholder:placeHolderImage];         //shows the image
        
        //calls the delegate to advise that the image is loaded.
        if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(mediaFinishLoading:)]){
            [self.delegate mediaFinishLoading:self.currentCampaignDTO];
        }
        
        //Notify the impression to Malcom server
        [MCMCampaignsHelper notifyServer:kCampaignImpressionHit andCampaign:self.currentCampaignDTO];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    MCMLog(@"Failed campaign loagin... %@",[error description]);
    
    self.dataMedia = nil;
    
    //calls the delegate telling that the loading failed
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(mediaFailedLoading:)]) {
        [self.delegate mediaFailedLoading:self.currentCampaignDTO];
    }
    
}


@end
