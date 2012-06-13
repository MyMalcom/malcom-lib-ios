
#import "MCANewsDetailViewController.h"


@implementation MCANewsDetailViewController

@synthesize newsItem=newsItem_;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    NSDictionary *style = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MCANews.bundle/NewsStyle.plist" ofType:nil]];

	//All the information will be in a web view
	webView_=[[UIWebView alloc]initWithFrame:self.view.bounds];	
	
	//The configuration is with autoresizing to avoid problems with the resize.
	[webView_ setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	[self.view addSubview:webView_];
    
	//Configuration of the web view an its elements
	NSString *path = [[NSBundle mainBundle] pathForResource:@"MCANews.bundle/NewsDetail.html" ofType:nil];
	NSString *pathImageBackground = [[NSBundle mainBundle] pathForResource:@"MCANews.bundle/NewsDetailBackground.png" ofType:nil];
	NSString *pathImageOneLine = [[NSBundle mainBundle] pathForResource:@"MCANews.bundle/NewsDetailSeparator.png" ofType:nil];
	NSString *formatHtml = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
	
	//configuration of the date format
	[dateFormatter setDateFormat:[style valueForKey:@"NewsDateFormat"]];
    NSString *dateStr = [dateFormatter stringFromDate:newsItem_.date];
    
	//Call to the method that will built the web view with the information that it requires.
	NSString *html = [NSString stringWithFormat:formatHtml, 
					  pathImageBackground,
					  (newsItem_.summary? newsItem_.summary : @""),
					  (newsItem_.title? newsItem_.title : @""),
					  (newsItem_.author? newsItem_.author : @""),
					  (dateStr? dateStr : @""),
					  pathImageOneLine,
					  ([newsItem_.images count]>0)? @"block":@"none",
					  ([newsItem_.images count]>0)? [newsItem_.images objectAtIndex:0]: @"",
					  pathImageOneLine,
					  (newsItem_.body? newsItem_.body : @"")];
	
    [dateFormatter release];
    
	//the news description is null or the length is not enought
	if ((newsItem_.body==nil)||([newsItem_.body length]<20)){
		NSURL * url = [NSURL URLWithString:newsItem_.link];
		if(url!=nil){
			//configuration of the indicator view
			viewIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			viewIndicator_.frame=CGRectMake(145, 160, 25, 25);
			viewIndicator_.tag  = 1;
			[webView_ addSubview:viewIndicator_];			
			[viewIndicator_ startAnimating];
			
			[webView_ setDelegate:self];
			[webView_ loadRequest:[NSURLRequest requestWithURL:url]]; //loading the external web page
		}else { //the news has all the things that we need
			[webView_ loadHTMLString:html baseURL:[NSURL URLWithString:[[NSBundle mainBundle] resourcePath]]];
		}
        
	}else {
		[webView_ loadHTMLString:html baseURL:[NSURL URLWithString:[[NSBundle mainBundle] resourcePath]]];
	}
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[webView_ release]; webView_ = nil;
	[viewIndicator_ release]; viewIndicator_ = nil;	
	self.newsItem=nil;
}


- (void)dealloc {
    [super dealloc];
	[webView_ release];
	[viewIndicator_ release];
	self.newsItem=nil;
}

#pragma mark UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [viewIndicator_ stopAnimating];
}




@end
