//
//  MCMIntersitialBannerViewController.m
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 24/01/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MCMIntersitialBannerViewController.h"

#define TOP @"TOP"
#define BOTTOM @"BOTTOM"
#define FULLSCREEN @"FULL_SCREEN"
#define MIDDLE_LANDSCAPE @"MIDDLE_LANDSCAPE"
#define MIDDLE_PORTRAIT @"MIDDLE_PORTRAIT"

#define bannerHeight 55.0
#define offset 20.0
#define statusBarOffset 20.0
#define lateralOffsets 10.0

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    
    [self.view removeFromSuperview];
    
}

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
//                id rootVC = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];

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


-(void)configureView{
    CGRect frameScreen = [[UIScreen mainScreen] bounds];
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    //reframes the banner
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
    else{ //middleLanscape,middlePortrait or FullScreen
        
        frame = CGRectMake(lateralOffsets, lateralOffsets, frameScreen.size.width - lateralOffsets*2, frameScreen.size.height - 40);
    }
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view setFrame:frame];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [button setBackgroundColor:[UIColor clearColor]];
    
    NSURL *url = [NSURL URLWithString:self.currentCampaignModel.media];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openURLAppstore) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    if([self.currentCampaignModel.position isEqualToString:MIDDLE_LANDSCAPE] || [self.currentCampaignModel.position isEqualToString:MIDDLE_PORTRAIT] || [self.currentCampaignModel.position isEqualToString:FULLSCREEN]){
        
        int yOffset = 0;
        //if the status bar is visible
        if ([UIApplication sharedApplication].statusBarHidden == NO){
            yOffset = statusBarOffset;
        }
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-45, 10+yOffset, 30, 30)];
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
        [closeButton setBackgroundColor:[UIColor blackColor]];
        [closeButton setTitle:@"X" forState:UIControlStateNormal];
        [closeButton.titleLabel setTextColor:[UIColor whiteColor]];
        [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [closeButton.layer setCornerRadius:14.0f];
        [closeButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [closeButton.layer setBorderWidth:1.5f];
        [closeButton.layer setShadowColor:[UIColor blackColor].CGColor];
        [closeButton.layer setShadowOpacity:0.8];
        [closeButton.layer setShadowRadius:3.0];
        [closeButton.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        [self.view addSubview:closeButton];
        [closeButton release];
    }
    
    
    
    //Animate to show
	
	//[self.view setFrame:CGRectMake(0, 0, self.view.superview.frame.size.width, self.view.superview.frame.size.height)];
    //	[UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationDuration:0.6];
    //	[self.view setFrame:frame];
    //	[UIView commitAnimations];
	
    //Be sure that it still on top when finish animation and during all the web life
    [self.view.superview performSelector:@selector(bringSubviewToFront:) withObject:self.view];

}

// Sent if the user requests that the page be dismissed
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    
    [viewController dismissModalViewControllerAnimated:YES];

    [self configureView];
}

-(BOOL)needsToDisplayOnWindow{
    
    //in case the type is TOP or BOTTOM it will be shown in the specified view
    if ([self.currentCampaignModel.position isEqualToString:TOP] || [self.currentCampaignModel.position isEqualToString:BOTTOM]) {
        return NO;
    }else{ //otherwise it needs to be displayed on the window on the top of everyview (navbars, tabbars..)
        return YES;
    }
}

@end
