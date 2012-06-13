//
//  ASIInputStream.h
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 10/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCMASIHTTPRequest;

// This is a wrapper for NSInputStream that pretends to be an NSInputStream itself
// Subclassing NSInputStream seems to be tricky, and may involve overriding undocumented methods, so we'll cheat instead.
// It is used by ASIHTTPRequest whenever we have a request body, and handles measuring and throttling the bandwidth used for uploading

@interface MCMASIInputStream : NSObject {
	NSInputStream *stream;
	MCMASIHTTPRequest *request;
}
+ (id)inputStreamWithFileAtPath:(NSString *)path request:(MCMASIHTTPRequest *)request;
+ (id)inputStreamWithData:(NSData *)data request:(MCMASIHTTPRequest *)request;

@property (retain, nonatomic) NSInputStream *stream;
@property (assign, nonatomic) MCMASIHTTPRequest *request;
@end
