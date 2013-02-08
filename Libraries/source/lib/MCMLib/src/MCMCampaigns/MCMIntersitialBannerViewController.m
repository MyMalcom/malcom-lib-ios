//
//  MCMIntersitialBannerViewController.m
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 24/01/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import "MCMIntersitialBannerViewController.h"

#define TOP @"TOP"
#define BOTTOM @"BOTTOM"
#define FULLSCREEN @"FULL_SCREEN"

#define bannerSize 55.0
#define offset 20.0

@interface MCMIntersitialBannerViewController ()

@end

@implementation MCMIntersitialBannerViewController

@synthesize urlAppStore = _urlAppStore;
@synthesize urlImage = _urlImage;
@synthesize type = _type;
@synthesize position = _position;

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
    CGRect frameScreen = [[UIScreen mainScreen] bounds];
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    if ([_position isEqualToString:TOP]) {
        
        frame = CGRectMake(0, 0, frameScreen.size.width, bannerSize);
        
    }
    else if ([_position isEqualToString:BOTTOM]) {
    
        frame = CGRectMake(0, frameScreen.size.height - bannerSize - offset, frameScreen.size.width, bannerSize);
    
    }
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view setFrame:frame];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [button setBackgroundColor:[UIColor clearColor]];
    NSURL *url = [NSURL URLWithString:_urlImage];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openURLAppstore) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    if ([_position isEqualToString:FULLSCREEN]) {
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-45, 10, 35, 35)];
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
        [closeButton setBackgroundColor:[UIColor blackColor]];
        [closeButton setTitle:@"X" forState:UIControlStateNormal];
        [closeButton.titleLabel setTextColor:[UIColor whiteColor]];
        [closeButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
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
        NSNumber * idApple = [f numberFromString:_urlAppStore];
        [f release];
        NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : idApple };
        
        
        [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
            if (result) {
                [self presentViewController:storeController animated:YES completion:nil];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"There was a problem displaying the app" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        }];
        
        
    } else { // Before iOS 6, we can only open the URL
      
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/es/app/id%@", _urlAppStore]]];
        
    }
    
}

// Sent if the user requests that the page be dismissed
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    
    [viewController dismissModalViewControllerAnimated:YES];
    CGRect frameScreen = [[UIScreen mainScreen] bounds];
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    if ([_position isEqualToString:TOP]) {
        
        frame = CGRectMake(0, 0, frameScreen.size.width, bannerSize);
        
    }
    else if ([_position isEqualToString:BOTTOM]) {
        
        frame = CGRectMake(0, frameScreen.size.height - bannerSize - offset, frameScreen.size.width, bannerSize);
        
    }
    
    [self.view setFrame:frame];
    
}

@end
