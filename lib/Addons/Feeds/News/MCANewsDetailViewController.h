
#import <UIKit/UIKit.h>
#import "MVYFeedItem.h"
#import "MCMViewController.h"

@interface MCANewsDetailViewController : MCMViewController <UIWebViewDelegate>{
    
	UIWebView *webView_;
	UIActivityIndicatorView *viewIndicator_;	
	MVYFeedItem *newsItem_;
}

@property (nonatomic, retain) MVYFeedItem *newsItem;


@end
