//
//  MPGlobal.h
//  MoPub
//
//  Created by Andrew He on 5/5/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIInterfaceOrientation MPInterfaceOrientation(void);
UIWindow *MPKeyWindow(void);
CGFloat MPStatusBarHeight(void);
CGRect MPApplicationFrame(void);
CGRect MPScreenBounds(void);
CGFloat MPDeviceScaleFactor(void);
NSString *MPHashedUDID(void);
NSString *MPUserAgentString(void);
NSDictionary *MPDictionaryFromQueryString(NSString *query);

@interface NSString (MPAdditions)

/* 
 * Returns string with reserved/unsafe characters encoded.
 */
- (NSString *)URLEncodedString;

@end