//
//  AdInfo.h
//  View2Road
//
//  Copyright 2010 Mobaloo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AdInfo : NSObject {
@private
	NSString *adFormat;
	NSString *_adURL;
	NSString *adClick;
	NSString *adEfectoBanner;
    NSString *adURLAudio;

}

- (id) initAdInfo;

@property (retain) NSString *adFormat;
@property (nonatomic,retain) NSString *adURL;
@property (retain) NSString *adClick;
@property (retain) NSString *adEfectoBanner;
@property (retain) NSString *adURLAudio;

@end
