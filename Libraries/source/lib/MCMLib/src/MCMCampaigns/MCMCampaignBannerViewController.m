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
#import "UIImageView+MCMWebCache.h"

#define ITUNES_URL @"https://itunes.apple.com/es/app/id%@"

#define bannerHeight 55.0
#define offset 20.0
#define statusBarOffset 20.0
#define lateralOffsets 10.0

#define middleLandscapeWidth 350.0f
#define middleLandscapeHeight 200.0f
#define middlePortraitWidth 240.0f
#define middlePortraitHeight 350.0f

@interface MCMCampaignBannerViewController ()

@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UIView *backgroundFadedView;      //faded view for middle banners
@property (nonatomic, retain) UIButton *closeButton;            //button to close the campaign
@property (nonatomic, retain) UIButton *bannerButton;           //button with campaign
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

@end

@implementation MCMCampaignBannerViewController

@synthesize currentCampaignDTO = _currentCampaignModel;
@synthesize containerView;
@synthesize appstoreContainerView;
@synthesize backgroundFadedView;
@synthesize closeButton;
@synthesize bannerButton;
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

- (void)viewDidAppear:(BOOL)animated {
    
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
//        [self rotateAccordingToStatusBarOrientationAndSupportedOrientations]; //use this method if you want to rotate everything
        
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
    }
    
    [MCMCampaignsHelper notifyServer:@"CLICK" andCampaign:self.currentCampaignDTO];
    
}


/**
 Method that opens the appstore inside the app or in another web view depending on the iOS version. As well, sends the campaignHit click event.
 @since 2.0.0
 */
- (void)openURLAppstore{
    
    if(NSClassFromString(@"SKStoreProductViewController")) { // Checks for iOS 6 feature.
        
        SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
        storeController.delegate = self; // productViewControllerDidFinish
        
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * idApple = [f numberFromString:self.currentCampaignDTO.promotionIdentifier];
        [f release];
        NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : idApple };
        
        
        [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
            if (result) {
			//if it doesnt have where to place the appstoreView it will place it on the VC handler of the banner container view
                if(!self.appstoreContainerView){
                    id rootVC = [self.containerView nextResponder];
//                    id rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
                    [rootVC presentViewController:storeController animated:YES completion:nil];
                }else{ //if it is specified, it will be placed on the appstoreContainerView 
                    [(UIViewController *)[self.appstoreContainerView nextResponder] presentViewController:storeController animated:YES completion:nil];

                }
                
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"There was a problem displaying the app" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        }];
        
        
    } else { // Before iOS 6, we can only open the URL
              
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:ITUNES_URL, self.currentCampaignDTO.promotionIdentifier]]];
        
    }
    
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
    
    //Show the banner with the placeholder
    [self showBannerWithPlaceholder:self.placeHolderImage];
    
    NSURL *url = [NSURL URLWithString:self.currentCampaignDTO.media];
    
    UIImageView *imageBannerView = [[UIImageView alloc] init];
    [imageBannerView setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, MCMSDImageCacheType cacheType) {
        
        if (!error) {
            
            //When complete set the loaded image on the button
            [self.bannerButton setImage:image forState:UIControlStateNormal];//shows the image
            
            //calls the delegate to advise that the image is loaded.
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(mediaFinishLoading:)]){
                [self.delegate mediaFinishLoading:self.currentCampaignDTO];
            }
            
            //Notify the impression to Malcom server
            [MCMCampaignsHelper notifyServer:@"IMPRESSION" andCampaign:self.currentCampaignDTO];
            
        } else {
            
            //There was an error
            MCMLog(@"Failed campaign loagin... %@",[error description]);
            
            //calls the delegate telling that the loading failed
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(mediaFailedLoading:)]) {
                [self.delegate mediaFailedLoading:self.currentCampaignDTO];
            }
        }
        
    }];

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

        if(self.currentCampaignDTO.position == MIDDLE_LANDSCAPE){
            width = middleLandscapeWidth;
            height = middleLandscapeHeight;
        }else if(self.currentCampaignDTO.position == MIDDLE_PORTRAIT){
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
    [self.bannerButton setImage:placeholder forState:UIControlStateNormal];
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




#pragma mark - SKStoreProductViewControllerDelegate methods

// Sent if the user requests that the page be dismissed
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
}


@end
