//
//  MCMIntersitialBannerViewController.h
//  MalcomLib
//
//  Created by Alfonso Miranda Castro on 24/01/13.
//  Copyright (c) 2013 Malcom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface MCMIntersitialBannerViewController : UIViewController<SKStoreProductViewControllerDelegate>

@property (nonatomic, retain) NSString *urlAppStore;
@property (nonatomic, retain) NSString *urlImage;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *position;

@end
