//
//  MadvertiseAdWhirlAdapter.h
//  
//
//  Created by Alfonso Miranda Castro on 14/03/12.
//  Copyright (c) 2012 Malcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MadvertiseDelegationProtocol.h"
#import "AdWhirlView.h"

@interface MadvertiseAdWhirlAdapter : NSObject<MadvertiseDelegationProtocol>


// Metodo para la creacion del singleton
+ (MadvertiseAdWhirlAdapter *)sharedInstance;

- (id)initWithMadvertise:(AdWhirlView *)adWhirl;

@end
