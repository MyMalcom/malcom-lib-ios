
#import "MCMConfigSectionManager.h"
#import "MCMConfig.h"
#import "MCMConfigDefines.h"
#import "OPMLReader.h"
#import "MCMCoreSingleton.h"

#import "MCMASIHTTPRequest.h"
#import "MCMASIDownloadCache.h"
#import "MCMLog.h"

@interface MCMConfigSectionManager(private)<MCMASIHTTPRequestDelegate>

- (NSString *)iconPath:(Outline *)outline;
- (void) downloadIcons;
- (void) downloadIcon:(Outline *) outline;

@end


@implementation MCMConfigSectionManager SYNTHESIZE_SINGLETON_FOR_CLASS(MCMConfigSectionManager)

#pragma mark ----
#pragma mark Properties
#pragma mark ----
@synthesize updating, error, lastUpdate, loaded, localFilePath, iconsDownloaded, sectionsChanged;


#pragma mark ----
#pragma mark  Life cycle methods
#pragma mark ----

- (id) init {
	
	if ((self = [super init])){
		self.error=NO;
		self.updating=NO;
		self.loaded=NO;
		self.lastUpdate=nil;
		self.iconsDownloaded=NO;
        self.sectionsChanged=NO;
		self.localFilePath=[NSString stringWithFormat:@"%@%@%@", NSHomeDirectory(), @"/Documents/", kMalcomSectionsLocalName]; 
	}
	
	return self;
}

#pragma mark ----
#pragma mark  Public methods
#pragma mark ----


- (void)loadSectionsWithOPMLUrl:(NSURL *)url{	
	//Check the file exists in bundle
	NSString *bundlePath = [[NSBundle mainBundle] pathForResource:kMalcomSectionsLocalName ofType:nil];
	if ((bundlePath==nil) && (self.loaded==NO) && (self.error==NO)) {
        
        [MCMLog log:[NSString stringWithFormat:@"Malcom Config -  MCMConfigSectionManager There is no sections file in the bundle. You should include a settings file named '%@' with the default sections within your project", kMalcomSectionsLocalName]
             inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
        
	}
	
	//Check if the settings is already in the local file or load it from bundle
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.localFilePath];
	if ((fileExists==NO) && (bundlePath!=nil)){
		[[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:self.localFilePath error:nil];
		fileExists=YES;
	}
	
	//If local file exists
	if (fileExists){		
		
		//Load the sections from the local file
		NSData *data=[NSData dataWithContentsOfFile:self.localFilePath];
		OPMLReader *reader = [[OPMLReader alloc] initWithData:data];
		if (reader.opml){
			//Retain the current OPML
			[opml_ release];
			opml_=[reader.opml retain];			
            self.iconsDownloaded=NO;
			self.lastUpdate=[[[NSFileManager defaultManager] attributesOfItemAtPath:self.localFilePath error:nil] objectForKey:NSFileModificationDate];
			self.error=NO;
			self.loaded=YES;
			
			//Download section icons
			[self performSelectorInBackground:@selector(downloadIcons) withObject:nil];
			
			//Post notification for the settings update
			[[NSNotificationCenter defaultCenter] postNotificationName:MCMConfigSectionsUpdateNotification object:nil];
		}
		[reader release];		
	}
	else {
		self.error=YES;
	}
	
	//Check if it must update the sections
	if (url){
		[self refreshSectionsForUrl:url];		
	}
}

- (void) refreshSectionsForUrl:(NSURL *)url{
	
	//Check there is not already updating
	if (self.updating) return;	
	self.updating=YES;
	    
    //Create the url
	if (url==nil){
        [self requestFailed:nil];
		return;
	}	
    
    MCMASIHTTPRequest *request = [MCMASIHTTPRequest requestWithURL:url];
    [request setDownloadCache:[MCMASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setTimeOutSeconds:kMalcomSettingsTimeout];
    [request setDelegate:self];
    [request startAsynchronous];
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Config - MCMConfigSectionManager Updating sections file from %@", [url absoluteString]]
         inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
}

- (UIViewController *) newViewControllerForSection:(int)section{
    
	//Check the section is valid
    if ((section >=[opml_.body.outlines count]) || (section<0))
        return nil;
    
    Outline *outline = [opml_.body.outlines objectAtIndex:section];
    
	//Get the main parameters
	id vc=nil;
	NSString *name=outline.text;
	NSString *type=outline.description;	            
    if (name==nil){
        return nil;
    }
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    for (Outline *o in outline.outlines){
        if ([o.xmlUrl length]>0)
            [urls addObject:o.xmlUrl];
    }
    
    //If controller set, try to load
	if (type!=nil){
        //Try to get the associated nib based on the section type following some rules:
        //1. Try appending the "View" suffix
        NSString *nibName=[NSString stringWithFormat:@"%@View", type];
        if ([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"]==nil){
            //2. Try appending the "ViewController" suffix
            nibName = [NSString stringWithFormat:@"%@ViewController", type];
            if ([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"]==nil){
                //3, try with the base type
                nibName = type;
                if ([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"]==nil){
                    nibName=nil;
                }			
            }
        }
        
        //Create the view controller based on the section type following some rules:
        //1, try appending "ViewController" suffix
        vc = [[NSClassFromString([NSString stringWithFormat:@"%@ViewController", type]) alloc] initWithNibName:nibName bundle:nil];
        
        //2, try appending "Controller" suffix
        if (vc==nil){
            vc = [[NSClassFromString([NSString stringWithFormat:@"%@Controller", type]) alloc] initWithNibName:nibName bundle:nil];	
        }
        
        //3, try appending "VC" suffix
        if (vc==nil){
            vc = [[NSClassFromString([NSString stringWithFormat:@"%@VC", type]) alloc] initWithNibName:nibName bundle:nil];	
        }
        
        //4, try with the base type
        if (vc==nil){
            vc = [[NSClassFromString(type) alloc] initWithNibName:nibName bundle:nil];	
        }
        
        if ((vc!=nil) && ([vc isKindOfClass:[UIViewController class]]==NO)) {
            
            [MCMLog log:[NSString stringWithFormat:@"Malcom Config - MCMConfigSectionManager %@ is not a UIViewController subclass", NSStringFromClass([vc class])]
                 inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
            [vc release]; vc=nil;
        }             
    }
    
    //If no controller loaded, try to load the MalcomAddOns
    if (vc==nil){
        if ([outline.type isEqualToString:@"web"]){
            vc = [[NSClassFromString(@"MCAWebBrowserViewController") alloc] initWithNibName:nil bundle:nil];	
            if (vc==nil){
                
                [MCMLog log:@"Malcom Config - MCMConfigSectionManager You need to include the Malcom AddOns in order to create Web sections"
                     inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
                
            }
        }
        else if ([outline.type isEqualToString:@"image"]){
            vc = [[NSClassFromString(@"MCAImageListViewController") alloc] initWithNibName:@"MCAImageListView" bundle:nil];	            
            if (vc==nil) {
                
                [MCMLog log:@"Malcom Config - MCMConfigSectionManager You need to include the Malcom AddOns in order to create image sections" 
                     inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
            }
        }
        else if ([outline.type isEqualToString:@"rss"]){
            vc = [[NSClassFromString(@"MCANewsListViewController") alloc] initWithNibName:@"MCANewsListView" bundle:nil];	            
            if (vc==nil) {
                
                [MCMLog log:@"Malcom Config - MCMConfigSectionManager You need to include the Malcom AddOns in order to create feed sections"
                     inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
                
            }
        }
    }
    
    //If a controller is succesfully loaded
    if (vc){
        
        //Set the properties for the controller
        [vc setTitle:name];
        
        NSString *icon=[self iconPath:outline];
        if (icon){
            [[vc tabBarItem] setImage:[UIImage imageWithContentsOfFile:icon]];
        }
        if ([vc respondsToSelector:@selector(setUrls:)]){
            [vc performSelector:@selector(setUrls:) withObject:urls];
        } else if ([vc respondsToSelector:@selector(setUrl:)]){
            [vc performSelector:@selector(setUrl:) withObject:[urls lastObject]];
        }    
    }
    
    [urls release];
	return vc;
}

- (NSArray *) sectionViewControllers{
	NSMutableArray *controllers = [[NSMutableArray alloc] init];
	
	//For each outline, try to instantiate
	for (int i=0; i<[opml_.body.outlines count]; i++){
		UIViewController *vc = [self newViewControllerForSection:i];
		if ([vc isKindOfClass:[UIViewController class]])
			[controllers addObject:vc];
		[vc release];
	}
	
	return [controllers autorelease];
}


#pragma mark ----
#pragma mark  Private methods
#pragma mark ----


- (void) downloadIcons{	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//Keep the current OPML because it can be changed if new sections come
	OPML *opml = [opml_ retain];
	
    //Get the icons to download
    NSMutableArray *iconsToDownload = [[NSMutableArray alloc] init];
    for (Outline *o in opml.body.outlines){
        NSString *path = [self iconPath:o];
        if ((path!=nil) && ([[NSFileManager defaultManager] fileExistsAtPath:path]==NO)){
            [iconsToDownload addObject:o];
        }
    }

    //Download the icons
    if ([iconsToDownload count]>0){
        for (Outline *o in iconsToDownload){
            [self downloadIcon:o];
        }        
    
    }
    //Notify icons downloaded
    self.iconsDownloaded=YES;    
    
    //Release objects
	[iconsToDownload release];
	[opml release];
	[pool release];
}

- (void) downloadIcon:(Outline *) outline {
    NSString *path = [self iconPath:outline];
    NSURL *url = [NSURL URLWithString:outline.url];
    NSURLRequest *req=[NSURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    if ([data length]>0){
        [data writeToFile:path atomically:NO];
    }
}

- (NSString *)iconPath:(Outline *)outline{
    NSString *iconName = outline.url;
    if (iconName==nil) return nil;
    
    //If it's a url we have to use a new path based on the url
    if ([iconName rangeOfString:@"http://"].location!=NSNotFound){
        return [NSString stringWithFormat:@"%@/%@/icon_%U.png", NSHomeDirectory(), @"Documents", [iconName hash]]; 
    }
    //If not a url, look in the local file bundle
    else {
        return [[NSBundle mainBundle] pathForResource:iconName ofType:nil];
    }
}


#pragma mark ----
#pragma mark ASIHTTPRequest delegate methods
#pragma mark ----


- (void)requestFinished:(MCMASIHTTPRequest *)request
{    
    if ([request didUseCachedResponse]==NO){
        // Use when fetching binary data
        NSData *data = [request responseData];

        //Check there is data
        if ([data length]<=0){
            [self requestFailed:request];
            return;
        }
        
        //Check if the data is equal to the last loaded
        NSData *oldData = [NSData dataWithContentsOfFile:[self localFilePath]];
        if (([oldData length]<=0) || ([data isEqualToData:oldData]==NO)){
            
            //Load the sections with the new content to check is correct
            OPMLReader *reader = [[OPMLReader alloc] initWithData:data];
            if (reader.opml){
                //If OK, store the new OPML in file disc			
                [data writeToFile:self.localFilePath atomically:NO];
                
                //Set the change
                self.sectionsChanged=YES;
                
                //Reload settings from cached file
                [self loadSectionsWithOPMLUrl:nil];		
                
                [reader release];
            }
            else {			
                [self requestFailed:request];                
                [reader release];
                return;	
            }
        }
    }
        
    //Refresh the properties
    self.error=NO;
    self.updating=NO;	
    
}

- (void)requestFailed:(MCMASIHTTPRequest *)request
{
    NSError *err = [request error];
    
    [MCMLog log:[NSString stringWithFormat:@"Malcom Config - MCMConfigSectionManager Error receiving the sections file: %@", [err description]] inLine:__LINE__ fromMethod:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]];
    
	self.error=YES;
	self.updating=NO;
}




@end
