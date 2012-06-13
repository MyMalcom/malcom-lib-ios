

#import "MCAImageListViewController.h"
#import "MVYImageView.h"
#import "MCAImageDetailViewController.h"

#import <stdlib.h>
#import <time.h>

#define kTagImage 2000

@interface MCAImageListViewController (private)

- (void) loadRandImage:(NSInteger)pos;
- (void) changeRandomImage;
- (void) changeAllImages;

@end


@implementation MCAImageListViewController

@synthesize scrollView = scrollView_;
@synthesize indicator = indicator_;
@synthesize noDataView = noDataView_;
@synthesize url = url_;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
    [super viewDidLoad];
    
    [noDataView_ setText:NSLocalizedString(@"No photos available", @"")];
    
    srand(time(NULL));
    
	if (feed_ == nil) {
		feed_ = [[[MVYFeedManager sharedInstance] feedForURL:[NSURL URLWithString:url_]] retain];
		[feed_ addObserver:self forKeyPath:@"updating" options:NSKeyValueObservingOptionNew context:nil];
	}
	if (feed_.updating) {
		[indicator_ startAnimating];
	}
	[self loadPhotos];
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.scrollView = nil;
	self.noDataView=nil;
	self.indicator = nil;
}


- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    timer_ = [[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(changeRandomImage) userInfo:nil repeats:YES] retain];    
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [timer_ invalidate];
    [timer_ release]; timer_=nil;
}

- (void)dealloc {
	self.scrollView = nil;
	self.indicator = nil;
	self.noDataView=nil;
	self.url=nil;
    [feed_ removeObserver:self forKeyPath:@"updating"];
	[feed_ release]; feed_=nil;
    [itemsWithPhotos_ release]; itemsWithPhotos_=nil;
    [super dealloc];
}

#pragma mark KeyValue Observing methods

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	
	if ((object==feed_) && (feed_.updating==NO)){	
		[indicator_ stopAnimating];
		[self loadPhotos];
	}
}


#pragma mark class methods

-(void) loadPhotos{
    if ([NSThread isMainThread]==NO){
        [self performSelectorOnMainThread:@selector(loadPhotos) withObject:nil waitUntilDone:NO];
        return;
    }
    
    @synchronized(self){
        //Remove old info
        NSArray *subviews = [scrollView_ subviews];
        for (UIView *view in subviews){
            [view removeFromSuperview];
        }
        [itemsWithPhotos_ release];
        itemsWithPhotos_=[[NSMutableArray alloc] init];
        
        int posX=3;
        int posY=3;
        int numeroItem=0;
        for (MVYFeedItem *item in feed_.items){
            if ([item.images count]>0) {
                [itemsWithPhotos_ addObject:item];
                
                //Container view
                UIView *container = [[UIView alloc] initWithFrame:CGRectMake(posX, posY, 100, 100)];
                [container setTag:numeroItem];
                
                //Image view
                MVYImageView *image = [[MVYImageView alloc]initWithFrame:container.bounds];
                [image setContentMode:UIViewContentModeScaleAspectFill];
                [image setClipsToBounds:YES];
                [image setAppearEfect:NO];
                [image setImage:[UIImage imageNamed:@"MCAImages.bundle/ImagesPlaceholder.png"]];
                [image setTag:kTagImage];
                
                //Label view
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(container.frame.size.width/2, container.frame.size.height-18, container.frame.size.width/2, 18)];
                [label setBackgroundColor:[UIColor colorWithWhite:0.15 alpha:0.8]];
                [label setTextColor:[UIColor whiteColor]];
                [label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:11]];
                [label setTextAlignment:UITextAlignmentRight];
                [label setMinimumFontSize:9];
                [label setText:[NSString stringWithFormat:@"%d %@", [item.images count], ([item.images count]>1? NSLocalizedString(@"fotos", @"") : NSLocalizedString(@"foto", @""))]];
                
                //Button view
                UIButton *button = [[UIButton alloc] initWithFrame:container.bounds];
                [button addTarget:self action:@selector(selectedPhoto:) forControlEvents:UIControlEventTouchUpInside];
                
                //Add to the scroll
                [container addSubview:image];
                [container addSubview:label];
                [container addSubview:button];
                [scrollView_ addSubview:container];
                [button release];
                [label release];
                [image release];
                [container release];
                
                //Move position counters
                posX+=106;
                numeroItem++;
                if((numeroItem % 3)==0){
                    posY+=106;
                    posX = 3;
                }		
                
            }
            
        }
        int lenght = 106*((ceil(1.0*numeroItem/3.0)));
        [scrollView_ setContentSize:CGSizeMake(320, lenght)];
        
        if (numeroItem==0){
            [noDataView_ setHidden:NO];		
        }
        else {
            [noDataView_ setHidden:YES];
        }
        
        [self performSelectorOnMainThread:@selector(changeAllImages) withObject:nil waitUntilDone:NO];
    }
}

-(void) selectedPhoto:(id)sender{
	MCAImageDetailViewController *photoDetailViewController = [[MCAImageDetailViewController alloc] initWithNibName:@"MCAImageDetailView" bundle:nil];
	
    int itemNum = [[sender superview] tag];    
    if ([itemsWithPhotos_ count]>itemNum){
        photoDetailViewController.images = [[itemsWithPhotos_ objectAtIndex:itemNum]images];        
    }
	[self.navigationController pushViewController:photoDetailViewController animated:YES];
	[photoDetailViewController release];	
}


- (void) loadRandImage:(NSInteger)pos{
    MVYImageView *image = (MVYImageView *)[[scrollView_ viewWithTag:pos] viewWithTag:kTagImage];
    
    if (image.updating) return;
    
    if ([itemsWithPhotos_ count]>pos){
        MVYFeedItem *item = [itemsWithPhotos_ objectAtIndex:pos];
        int rand = random() % [item.images count];
        if ([item.images count]>rand){
            [image setAppearEfect:YES];
            [image setEffectWithCache:YES];
            [image loadImageFromURL:[NSURL URLWithString:[item.images objectAtIndex:rand]] loadingImage:image.image];
            
            lastRandom_=pos;
        }
    }
}

- (void) changeRandomImage{
    if ([NSThread isMainThread]==NO){
        [self performSelectorOnMainThread:@selector(changeRandomImage) withObject:nil waitUntilDone:NO];
    }
    
    int rand = random() % [itemsWithPhotos_ count];
    if (rand==lastRandom_)
        rand = (rand+1) % [itemsWithPhotos_ count];
    
    [self loadRandImage:rand];
}

- (void) changeAllImages {
    if ([NSThread isMainThread]==NO){
        [self performSelectorOnMainThread:@selector(changeAllImages) withObject:nil waitUntilDone:NO];
        return;
    }
    
    for (int i=0; i<[itemsWithPhotos_ count]; i++){
        [self loadRandImage:i];
    }
}

@end
