
#import <UIKit/UIKit.h>
#import "MCMViewController.h"

@interface MCAImageDetailViewController : MCMViewController<UIScrollViewDelegate, UIWebViewDelegate, UIActionSheetDelegate>{
	IBOutlet UIScrollView *scrollView_;          //Horizontal Scroll View that contains all the pics
	IBOutlet UIActivityIndicatorView *indicator_;      //Activity Indicator View that appears when loading the images
	IBOutlet UIToolbar *toolbar_;			//Toolbar of actions
	IBOutlet UIBarButtonItem *prevBarButtonItem_;  //Button to show the previous image (disabled if showing the first image)
	IBOutlet UIBarButtonItem *nextBarButtonItem_;  //Button to show the next image (disabled if showing the last image)
	IBOutlet UIBarButtonItem *playBarButtonItem_;	//Play button to start/stop show
    IBOutlet UIToolbar *navbar_;        //Navigation bar
    IBOutlet UIBarButtonItem *titleItem_;
	IBOutlet UIButton *backgroundButton_;		//A background button to detect touches over the image
	NSInteger scrollPageNumber_;                   //Page Number that is currently shown in the scroll view
	NSArray *images_;                    //Array of all the Pictures of this gallery
	BOOL mustShowToolbars_;
	NSTimer *timer;			//Timer to change image while playing show
	
}

@property (nonatomic, retain) NSArray *images;
@property NSInteger scrollPageNumber;

- (IBAction)nextImage:(id)sender;
- (IBAction)previousImage:(id)sender;
- (IBAction)playPauseShow:(id)sender;
- (IBAction)pushBack:(id)sender;
- (IBAction)touchOnImage:(id)sender;


@end
