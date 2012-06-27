
#import "MSMCMAdapter.h"


@implementation  MCMAdAdapter (MediaSmart)
- (void)mediasmartLoadAd:(AdWhirlView *)awView
{
    
    NSLog(@"___________________________mediasmartLoadAd");
    
   [AdWhirlCustomEventAdapterMoPub 
			requestMoPubAdForAdUnitID:[MSConfig sharedInstance].adunit
			withAdWhirlDelegate:awView.delegate 
			forAdWhirlView:awView];
	[self adWhirlDidReceiveAd:awView];
}
- (NSString *)keywords{
	return [MSConfig sharedInstance].keywords;
}; 
@end



static MSConfig *sharedInstance = nil;

@implementation MSConfig

@synthesize keywords;
@synthesize adunit;

#pragma mark Singleton Methods
+ (id)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}
- (id)init {
    if (self = [super init]) {
        keywords = [[NSString stringWithString:@""] retain];
        adunit = [[NSString stringWithString:@""] retain];

    }
    return self;
}
- (void)dealloc {
	[keywords release];
	keywords=nil;
    [adunit release];
	adunit=nil;
	[super dealloc];
}


@end

