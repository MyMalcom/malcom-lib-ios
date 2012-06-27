//
//  Manager.h
//  AdMobalooBannerPruebas
//
//  Created by Lupus on 02/08/11.
//  Copyright 2011 Dpto. Técnico. All rights reserved.
//

#import <foundation/Foundation.h>

@interface Manager : NSObject {
    NSMutableArray *timers;
}
@property (nonatomic, retain) NSMutableArray *timers;



+ (id)sharedManager;

@end