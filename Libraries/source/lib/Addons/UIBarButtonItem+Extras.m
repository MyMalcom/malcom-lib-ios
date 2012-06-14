//
//  UIBarButtonItem+Extras.m
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 19/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIBarButtonItem+Extras.h"


@implementation UIBarButtonItem(Extras)


+ (UIBarButtonItem*)barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action{
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:image forState:UIControlStateNormal];	
	button.frame= CGRectMake(0.0, 0.0, image.size.width, image.size.height);	
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithCustomView:button];
	[button release];
	return [forward autorelease];
}

@end
