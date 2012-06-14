
#import <Foundation/Foundation.h>
#import "MCMModuleAdapter.h"

#import "AdWhirlDelegateProtocol.h"



/**
 Module adapter used by the MCMStats module. It's the delegate for AdWhirl and loads a banner in
 each view controller loadView method
 @since 1.0
 */
@interface MCMAdAdapter : MCMModuleAdapter<AdWhirlDelegate> {
    
    NSMutableDictionary *adViewDict_;

}

@end
