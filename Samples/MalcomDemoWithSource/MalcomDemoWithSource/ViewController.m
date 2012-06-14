//
//  ViewController.m
//  MalcomDemoWithSource
//
//  Created by Alfonso Miranda Castro on 13/06/12.
//  Copyright (c) 2012 Malcom. All rights reserved.
//

#import "ViewController.h"
#import "MalcomLib.h"
#import "MalcomAd.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [MalcomLib startBeaconWithName:@"ViewController"];
    
    [MalcomAd presentAd:self atPosition:CGPointMake(0, 0)];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [MalcomLib endBeaconWithName:@"ViewController"];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
