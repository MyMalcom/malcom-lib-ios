//
//  MSMCMAdapter.h
//  MobiveryApp
//
//  Created by Guillermo Fernandez on 13/04/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCMAdAdapter.h"
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#import "AdWhirlCustomEventAdapterMoPub.h"

@interface MCMAdAdapter (MediaSmart) 
	- (void)mediasmartLoadAd:(AdWhirlView *)awView;
@end


@interface MSConfig : NSObject
{
		NSString* keywords;
        NSString*adunit;
}

	@property (nonatomic, copy) NSString *keywords;
    @property (nonatomic, copy) NSString *adunit;

	+(MSConfig*) sharedInstance;

@end

