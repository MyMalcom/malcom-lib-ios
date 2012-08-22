
#import "MCMNotificationUtils.h"
#import "MCMNotificationsDefines.h"
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>

@implementation MCMNotificationUtils

+ (NSString *) formatApnsTagString: (NSArray *) tags {
	
//	NSMutableString *tagsString = [[NSMutableString alloc] initWithString:@"["];	
//	for (int i = 0; i < [tags count]; i++)
//	{
//		[tagsString appendFormat:@"%@%@%@%@",kMCMNotificationsTagDelimiter,[tags objectAtIndex: i],kMCMNotificationsTagDelimiter,kMCMNotificationsTagSeparator];
//        
//	}
//    [tagsString appendString:@"]"];
//	NSString *tagsStringFormatted = [tagsString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
//    NSLog(@"%@", tagsStringFormatted);
//    [tagsString release]; 
    
    NSMutableString *tagsString = [[NSMutableString alloc] initWithString:@"["];
    
    for (int i = 0; i < [tags count]; i++)
    	{
    		[tagsString appendFormat:@"%@",[tags objectAtIndex: i]];
            
            if (i != [tags count] - 1) {
                
                [tagsString appendString:@","];
                
            }
            
    	}
    
    [tagsString appendString:@"]"];
    
	return tagsString;
	
}


@end
