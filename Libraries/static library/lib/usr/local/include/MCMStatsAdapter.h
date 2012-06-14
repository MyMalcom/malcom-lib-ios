
#import <Foundation/Foundation.h>
#import "MCMModuleAdapter.h"

/**
 Module adapter used by the MCMStats module. It's responsable of initializing the library, sending the stats 
 to Malcom when app terminates or enters in background and recieve the viewWillAppear events to register a beacon
 @since 1.0
 */
@interface MCMStatsAdapter : MCMModuleAdapter {
    
}

@end
