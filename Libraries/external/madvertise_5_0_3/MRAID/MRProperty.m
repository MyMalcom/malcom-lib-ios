//
//  MRProperty.m
//  MoPub
//
//  Created by Andrew He on 12/13/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import "MRProperty.h"

@implementation MRProperty

- (NSString *)description {
    return @"";  
}

- (NSString *)jsonString {
    return @"{}";
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MRPlacementTypeProperty : MRProperty

@synthesize placementType = _placementType;

+ (MRPlacementTypeProperty *)propertyWithType:(MRAdViewPlacementType)type {
    MRPlacementTypeProperty *property = [[[self alloc] init] autorelease];
    property.placementType = type;
    return property;
}

- (NSString *)description {
    NSString *placementTypeString = @"unknown";
    switch (_placementType) {
        case MRAdViewPlacementTypeInline: placementTypeString = @"inline"; break;
        case MRAdViewPlacementTypeInterstitial: placementTypeString = @"interstitial"; break;
        default: break;
    }
    
    return [NSString stringWithFormat:@"placementType: '%@'", placementTypeString]; 
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MRStateProperty

@synthesize state = _state;

+ (MRStateProperty *)propertyWithState:(MRAdViewState)state {
    MRStateProperty *property = [[[self alloc] init] autorelease];
    property.state = state;
    return property;
}

- (NSString *)description {
    NSString *stateString;
    switch (_state) {
        case MRAdViewStateHidden:      stateString = @"hidden"; break;
        case MRAdViewStateDefault:     stateString = @"default"; break;
        case MRAdViewStateExpanded:    stateString = @"expanded"; break;
        default:                       stateString = @"loading"; break;
    }
    return [NSString stringWithFormat:@"state: '%@'", stateString];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MRScreenSizeProperty : MRProperty

@synthesize screenSize = _screenSize;

+ (MRScreenSizeProperty *)propertyWithSize:(CGSize)size {
    MRScreenSizeProperty *property = [[[self alloc] init] autorelease];
    property.screenSize = size;
    return property;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"screenSize: {width: %f, height: %f}", 
            _screenSize.width, 
            _screenSize.height];  
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MRViewableProperty : MRProperty

@synthesize isViewable = _isViewable;

+ (MRViewableProperty *)propertyWithViewable:(BOOL)viewable {
    MRViewableProperty *property = [[[self alloc] init] autorelease];
    property.isViewable = viewable;
    return property;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"viewable: '%@'", _isViewable ? @"true" : @"false"];  
}

@end
