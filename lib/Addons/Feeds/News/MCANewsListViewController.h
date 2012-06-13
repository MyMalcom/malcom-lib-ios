
#import <UIKit/UIKit.h>
#import "MVYFeedManager.h"
#import "MCMViewController.h"

@interface MCANewsListViewController :MCMViewController <UITableViewDataSource,UITableViewDelegate>{
	UITableView *tableView_;
	MVYFeed *feed_;
	UIActivityIndicatorView *indicator_;
	UILabel *noDataView_;
	UILabel *updateLabel_;
	NSString *url_;
}

@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *indicator;
@property(nonatomic,retain)	IBOutlet UILabel *noDataView;
@property(nonatomic,retain)	IBOutlet UILabel *updateLabel;
@property(nonatomic,retain) NSString *url;


@end
