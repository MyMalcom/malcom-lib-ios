
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OPML.h"

/**
 Singleton class that manages the sections configured in Malcom Server. 
 @since 1.0
 */
@interface MCMConfigSectionManager : NSObject {
//	NSMutableData *data_;
	OPML *opml_;
}

#pragma mark ----
#pragma mark  Property declaration
#pragma mark ----

/**
 Shows if the section manager is already loaded with any section file
 @since 1.0
 */
@property BOOL loaded;

/**
 Shows if the section manager is updating the file from server
 @since 1.0
 */
@property BOOL updating;

/**
 Shows if the icons are already downloaded (if possible)
 @since 1.0
 */
@property BOOL iconsDownloaded;

/**
 Shows if the section manager encountered errors while updating
 @since 1.0
 */
@property BOOL error;

/**
 Shows the date of the last succesfully updated file
 @since 1.0
 */
@property(retain) NSDate *lastUpdate;

/**
 Indicate local file path of the downloaded file. By default in Documents/MCMSections.opml
 @since 1.0
 */
@property(retain) NSString *localFilePath;


/**
 Indicate if there is any change since the last update of the file
 @since 1.0
 */
@property BOOL sectionsChanged;


/**
 Gets the singleton instance for this class
 @returns Singleton object for the class
 @since 1.0
 */
+ (MCMConfigSectionManager *)sharedInstance;

/**
 Loads the last cached sections file and try to update it from the server if desired
 @param url URL for the remote sections file in Malcom. Could be nil if no update needed
 @since 1.0
 */
- (void)loadSectionsWithOPMLUrl:(NSURL *)url;

/**
 Forces the sections to be updated from the server with the given url. It does anything if it's already updating.
 Note this method is called automatically when "loadSectionsWithConfigUrl" is called with a proper parameter. 
 @param url Remote url used for updating
 @since 1.0
 */
- (void) refreshSectionsForUrl:(NSURL *)url;

/**
 Create the controller for a section specified in Malcom
 @param section Number of the section to create
 @return Controller associated to the section or nil if none or invalid
 @since 1.0 
 */
- (UIViewController *) newViewControllerForSection:(int)section;

/**
 Return an array of all the valid controllers configured in the section OPML file
 @return Array with all controllers valid
 @since 1.0 
 */
- (NSArray *) sectionViewControllers;

@end
