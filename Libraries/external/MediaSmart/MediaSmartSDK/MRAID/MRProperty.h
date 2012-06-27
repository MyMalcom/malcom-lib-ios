//
//  MRProperty.h
//  MoPub
//
//  Created by Andrew He on 12/13/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRAdView.h"

@interface MRProperty : NSObject

- (NSString *)description;
- (NSString *)jsonString;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRPlacementTypeProperty : MRProperty {
    MRAdViewPlacementType _placementType;
}

@property (nonatomic, assign) MRAdViewPlacementType placementType;

+ (MRPlacementTypeProperty *)propertyWithType:(MRAdViewPlacementType)type;

@end 

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRStateProperty : MRProperty {
    MRAdViewState _state;
}

@property (nonatomic, assign) MRAdViewState state;

+ (MRStateProperty *)propertyWithState:(MRAdViewState)state;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRScreenSizeProperty : MRProperty {
    CGSize _screenSize;
}

@property (nonatomic, assign) CGSize screenSize;

+ (MRScreenSizeProperty *)propertyWithSize:(CGSize)size;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRViewableProperty : MRProperty {
    BOOL _isViewable;
}

@property (nonatomic, assign) BOOL isViewable;

+ (MRViewableProperty *)propertyWithViewable:(BOOL)viewable;

@end
