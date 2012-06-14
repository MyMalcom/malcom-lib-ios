
#import <UIKit/UIKit.h>
#import "MVYFeedManager.h"
#import "MCMViewController.h"

@interface MCAImageListViewController : MCMViewController {
    
	UIScrollView *scrollView_;
	MVYFeed *feed_;
	UIActivityIndicatorView *indicator_;
	UILabel *noDataView_;
	NSString *url_;
    NSMutableArray *itemsWithPhotos_;
    NSTimer *timer_;
    int lastRandom_;
}

@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *indicator;
@property(nonatomic,retain)	IBOutlet UILabel *noDataView;
@property(nonatomic,retain) NSString *url;

-(void) loadPhotos;
-(void) selectedPhoto:(id)sender;



@end
