//
//  MalcomAd.m
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 06/06/12.
//  Copyright (c) 2012 Malcom. All rights reserved.
//

#import "MalcomAd.h"
#import "MCMAdManager.h"

@implementation MalcomAd

//  ADS

+ (void)presentAd:(UIViewController *)vc atPosition:(CGPoint)position withSize:(CGSize)size {
    
    CGRect rect = CGRectMake(position.x, position.y, size.width, size.height);
    
    [[MCMAdManager sharedInstance] presentAd:vc atPosition:rect];
    
}

+ (void)presentAd:(UIViewController *)vc atPosition:(CGPoint)position {
    
    CGRect rect = CGRectMake(position.x, position.y, 0, 0);
    
    [[MCMAdManager sharedInstance] presentAd:vc atPosition:rect];
    
}

+ (void)relocateAd:(CGPoint)position {
    
    [[MCMAdManager sharedInstance] relocateAd:position];
    
}

+ (void)removeAd:(UIViewController *)viewController {
    
    [[MCMAdManager sharedInstance] removeAd:viewController];
    
}

+ (id)getAd {
    
    return [[MCMAdManager sharedInstance] getAd];
    
}

@end
