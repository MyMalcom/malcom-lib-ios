
#import "MCANewsListViewController.h"
#import "MCANewsTableViewCell.h"
#import "MCANewsDetailViewController.h"
#import "UIBarButtonItem+Extras.h"

@interface MCANewsListViewController(private)

- (void) configureStatus;

@end


@implementation MCANewsListViewController

@synthesize tableView = tableView_;
@synthesize indicator = indicator_;
@synthesize noDataView = noDataView_;
@synthesize updateLabel=updateLabel_;
@synthesize url = url_;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
    [super viewDidLoad];
    
    [noDataView_ setText:NSLocalizedString(@"No news available", @"")];
    
	//Obtaining the RSS data
	if (feed_ == nil) {
		feed_ = [[[MVYFeedManager sharedInstance] feedForURL:[NSURL URLWithString:url_]] retain];
		[feed_ addObserver:self forKeyPath:@"updating" options:NSKeyValueObservingOptionNew context:nil];
	}
	[self configureStatus];
    
    // Creation of the button placed at the navigation bar
	self.navigationItem.rightBarButtonItem=[UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"MCANews.bundle/NewsRefresh.png"] target:self action:@selector(refreshAction)];
    
    
}


- (void)viewDidUnload {	
    [super viewDidUnload];
	
	// Release any retained subviews of the main view.
    self.tableView = nil;    
	self.indicator = nil;
	self.noDataView=nil;
	self.updateLabel=nil;
	self.url=nil;
}


- (void)dealloc {
	self.tableView = nil; 
	self.indicator = nil;
	self.noDataView=nil;
	self.updateLabel=nil;
	self.url=nil;
	[feed_ release];
    [super dealloc];
}


#pragma mark Metodos de la clase

- (void) configureStatus {
	if (feed_.updating) {
		[indicator_ startAnimating];
	}
	else {
		[indicator_ stopAnimating];
	}
    
	if ([feed_.items count]<=0)
		[noDataView_ setHidden:NO];
	else
		[noDataView_ setHidden:YES];
	
    
	if (feed_.lastUpdate==nil){
		[updateLabel_ setText:NSLocalizedString(@"No previuos data", @"")];
	}
	else {
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"dd MMMM yyyy, hh:mm"];
		NSString *dateStr = [formatter stringFromDate:feed_.lastUpdate];
		[updateLabel_ setText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Updated on", @""), dateStr]];
		[formatter release];
	}
	
}

- (void) refreshAction {
	if (feed_.updating==NO)
		[[MVYFeedManager sharedInstance] updateFeed:feed_];	
}

#pragma mark Metodos del UITableViewDelegate y UITableViewDatasource

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [feed_.items count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{	
	static NSString *CellIdentifier = nil;
	
	MCANewsTableViewCell *cell=nil;
	if (CellIdentifier)
		cell = (MCANewsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[MCANewsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	MVYFeedItem *item = nil;
	if (indexPath.row < [feed_.items count]) {
		item = [feed_.items objectAtIndex:indexPath.row];
	}
    [cell configureCell:item];
	
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	// Configure the table...
	MCANewsDetailViewController *vc=[[MCANewsDetailViewController alloc] init];
	MVYFeedItem *item = nil;
	if (indexPath.row < [feed_.items count]) {
		item = [feed_.items objectAtIndex:indexPath.row];
	}
    [vc setNewsItem:item];		
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}



#pragma mark KeyValue Observing methods


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)contex {
    
	if (object==feed_){	
		[tableView_ reloadData];
		[self configureStatus];
	}
}

@end
