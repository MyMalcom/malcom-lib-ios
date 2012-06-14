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
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) id<MCMConfigWebAlertDelegate> delegate;

- (void) show;

- (void) close;

@end
