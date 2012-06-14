//
//  MVYFeedParserDelegateAtom.h
//  MobiveryApp
//
//  Created by Angel Luis Garcia on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVYFeedParser.h"


@interface MVYFeedParserDelegateAtom : NSObject<MVYFeedParserDelegateProtocol> {

    NSDateFormatter *parseFormatter_;
    BOOL inAuthor_;
}

@end
