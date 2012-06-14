//
//  MCAImageDetailViewController.m
//  MCMLib
//
//  Created by Angel Luis Garcia on 17/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MCAImageDetailViewController.h"
#import "MVYImageView.h"

#define kTimeImagePlay 3.0

@interface MCAImageDetailViewController (Private)

- (void)loadAllImages;
- (void)setPageStatus;

@end


@implementation MCAImageDetailViewController

@synthesize scrollPageNumber=scrollPageNumber_;
@synthesize images=images_;


- (void)dealloc {
	
	//Eliminamos todas las imagenes para evitar problemas con peticiones en cola
	for (int i=[images_ count]-1; i>=0; i--){
		UIView *imagen=[scrollView_ viewWithTag:100+i];
		[imagen removeFromSuperview];
	}
	
	[scrollView_ release];
	[indicator_ release];
	[prevBarButtonItem_ release];
	[nextBarButtonItem_ release];
	[playBarButtonItem_ release];
    [navbar_ release];
    [titleItem_ release];
	[backgroundButton_ release];
	[toolbar_ release];
	
	[images_ release];
	[timer invalidate];
	
	[super dealloc];
}

#pragma mark UIViewController Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		mustShowToolbars_=YES;
		
		// Mandamos ocultar la TabBar cuando accedemos a la vista.
		[self setHidesBottomBarWhenPushed:YES];
		
	}
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	[scrollView_ setContentSize: CGSizeMake(320.0*[images_ count], 344.0)];	
	[backgroundButton_ setFrame:CGRectMake(0, 
										   backgroundButton_.frame.origin.y,
										   320.0*[images_ count], 
										   scrollView_.frame.size.height-backgroundButton_.frame.origin.y-toolbar_.frame.size.height)];	
	[self loadAllImages];
	[self setPageStatus];
	[scrollView_ setContentOffset: CGPointMake(320.0*scrollPageNumber_, 0.0) animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// Mandamos ocultar la navbar cuando accedemos a la vista.
	[self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:NO];	
}


#pragma mark Class Methods

- (void)loadAllImages {
	
	int page=0;
	for (NSString *urlImage in images_){
		MVYImageView *imgView = [[MVYImageView alloc] initWithFrame:CGRectMake(320.0*page, 0.0, 320.0, 460.0)];		
		[imgView setContentMode:UIViewContentModeScaleAspectFit];
		[imgView loadImageFromURL:[NSURL URLWithString:urlImage] loadingImage:nil];
		[imgView setTag:100+page];		
		[scrollView_ addSubview:imgView];		
		[imgView release];
		page++;		
	}
	
}

- (void)setPageStatus {
	int totalPages=[images_ count];
	
    [titleItem_ setTitle:[NSString stringWithFormat:@"%d / %d", scrollPageNumber_+1, totalPages]];
	
	if (scrollPageNumber_ > 0) {
		[prevBarButtonItem_ setEnabled: YES];
	}
	else {
		[prevBarButtonItem_ setEnabled: NO];
	}
	
	if (scrollPageNumber_ < totalPages-1) {
		[nextBarButtonItem_ setEnabled:YES];
	}
	else {
		[nextBarButtonItem_ setEnabled: NO];
	}
	
	MVYImageView *image = (MVYImageView *) [scrollView_ viewWithTag:100+scrollPageNumber_];
	if (image.updating){
		//[indicator_ startAnimating];		
	}
	else {
		[indicator_ stopAnimating];	
	}
}


#pragma mark UIScrollViewDelegate Methods


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	CGPoint offset = [scrollView contentOffset];
	scrollPageNumber_ = offset.x / 320.0;
    
	[self setPageStatus];
}


#pragma mark IBActions

- (IBAction)nextImage:(id)sender {
	if (scrollPageNumber_ < [images_ count]-1) {
		scrollPageNumber_++;
	}else{		//Si estamos en la ultima foto volvemos al principio
		scrollPageNumber_=0;  
	}
	[scrollView_ setContentOffset: CGPointMake(320.0*scrollPageNumber_, 0.0) animated:YES];
    [self setPageStatus];
}

- (IBAction)previousImage:(id)sender {
	if (scrollPageNumber_ > 0) {
		scrollPageNumber_--;
		[scrollView_ setContentOffset: CGPointMake(320.0*scrollPageNumber_, 0.0) animated:YES];
		[self setPageStatus];
	}
}


- (IBAction)playPauseShow:(id)sender{
	
	//Activamos el timer
	if (timer==nil){

        timer=[NSTimer scheduledTimerWithTimeInterval:kTimeImagePlay target:self selector:@selector(nextImage:) userInfo:nil repeats:YES];

		playBarButtonItem_.image=[UIImage imageNamed:@"MCAImages.bundle/ImagePause.png"];
		
    //Desactivamos el timer
	}else{
		[timer invalidate];
		timer=nil;
		playBarButtonItem_.image=[UIImage imageNamed:@"MCAImages.bundle/ImagePlay.png"];
	}	
}


- (IBAction)pushBack:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)touchOnImage:(id)sender{
	
	[UIView beginAnimations:nil context:NULL];				
	
	if (mustShowToolbars_){
        navbar_.frame=CGRectMake(0, 
                                 -navbar_.frame.size.height, 
                                 navbar_.frame.size.width, 
                                 navbar_.frame.size.height);
        
		toolbar_.frame=CGRectMake(0, 
								  toolbar_.frame.origin.y+toolbar_.frame.size.height, 
								  toolbar_.frame.size.width, 
								  toolbar_.frame.size.height);		
	}
	else {
        navbar_.frame=CGRectMake(0, 
                                 0, 
                                 navbar_.frame.size.width, 
                                 navbar_.frame.size.height);
        
		toolbar_.frame=CGRectMake(0, 
								  toolbar_.frame.origin.y-toolbar_.frame.size.height, 
								  toolbar_.frame.size.width, 
								  toolbar_.frame.size.height);		
		
	}
	mustShowToolbars_=!mustShowToolbars_;	
	[UIView commitAnimations];
}



#pragma mark Simple Key-Value Observing Implementation

// Override to perform custom actions on status changes
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	//Cuando se actualiza el channel
	if ([keyPath isEqual:@"updating"]){
		MVYImageView *image=object;
		//Si la observacion es de la imagen actual
		if (image.tag==100+scrollPageNumber_){
			if (image.updating){
				//[indicator_ startAnimating];
			}else{
				[indicator_ stopAnimating];							
            }
		}
	}
}

@end
