//
//  MCMCampaignsManager.h
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 25/01/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMCampaignsManager : NSObject {
    
    UIView *_showView;
    NSString *_campaingId;
    
}

/**
 Gets the singleton instance for this class
 @returns Singleton object for the class
 @since 1.0
 */
+ (MCMCampaignsManager *)sharedInstance;

- (void)addBanner:(UIView *)view;

@end
