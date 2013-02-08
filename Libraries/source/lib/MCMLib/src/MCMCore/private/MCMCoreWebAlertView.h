//
//  MCMCoreWebAlertView.h
//

#import <UIKit/UIKit.h>

@class MCMCoreWebAlertView;

@protocol MCMConfigWebAlertDelegate

- (void) webAlertClose:(MCMCoreWebAlertView *)alert;

@end


@interface MCMCoreWebAlertView : UIViewController<UIWebViewDelegate> {
	NSURL *url_;
	id<MCMConfigWebAlertDelegate> delegate_;
	
	UIWebView *webView_;
	UIButton *closeButton_;
	UIActivityIndicatorView *indicator_;
	
	BOOL showed_;
    BOOL statusHidden_;
    
    BOOL isBanner_;
    
    NSString *htmlString_;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) BOOL isBanner;
@property (nonatomic, retain) NSString *htmlString;
@property (nonatomic, assign) id<MCMConfigWebAlertDelegate> delegate;

- (void) show;

- (void) close;

@end
