
#import <UIKit/UIKit.h>
#import "MVYFeedItem.h"
#import "MVYImageView.h"

@interface MCANewsTableViewCell : UITableViewCell {
	MVYImageView *image_;
	UILabel *titleLabel_;
	UILabel	*authorLabel_;
	UILabel *dateLabel_;
    
	NSDateFormatter *dateFormatter_;
}

-(void) configureCell:(MVYFeedItem *)item;

@end