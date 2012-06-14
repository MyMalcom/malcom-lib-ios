//
//  MCANewsTableViewCell.m
//  MCMLib
//
//  Created by Angel Luis Garcia on 17/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MCANewsTableViewCell.h"
#import "UIColor+Extras.h"

@implementation MCANewsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSDictionary *style = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MCANews.bundle/NewsStyle.plist" ofType:nil]];
        
        
		// Configuration & Initialization of the cell apperanced.
		dateFormatter_ = [[NSDateFormatter alloc] init];
		[dateFormatter_ setDateFormat:[style valueForKey:@"NewsDateFormat"]];
		
		// Initialization of the background cell		
		UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MCANews.bundle/NewsCellBackground.png"]];
		self.backgroundView=img;
		[img release];
		
		// Initialization of the spacebar
	    UIImageView *imageLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 74, 320, 2)];
		[imageLine setImage:[UIImage imageNamed:@"MCANews.bundle/NewsCellSeparator.png"]];
		[self.contentView addSubview:imageLine];
		[imageLine release];
		
		// Initialization of the frame				
		UIImageView *imageFrame = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 82, 63)];
		[imageFrame setImage:[UIImage imageNamed:@"MCANews.bundle/NewsImageBackground.png"]];
		[self.contentView addSubview:imageFrame];		
		[imageFrame release];
        
		//Initialization of the picture associated with the news
		image_ = [[MVYImageView alloc]initWithFrame:CGRectMake(12, 12, 70, 50)];
		[image_ setContentMode:UIViewContentModeScaleAspectFill];
		[image_ setClipsToBounds:YES];
		[self.contentView addSubview:image_];
		
		// Initialization of the newss title
		titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 200, 45)];
        [titleLabel_ setFont:[UIFont fontWithName:[style valueForKey:@"NewsFontFamilyBold"] size:14]];
        [titleLabel_ setTextColor:[UIColor colorWithHexString:[style valueForKey:@"NewsMainColor"]]];
        
		[titleLabel_ setNumberOfLines:0];
		[titleLabel_ setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:titleLabel_];
        
		// Initialization of the newss author
		authorLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(100, 55, 0, 12)];
        [authorLabel_ setFont:[UIFont fontWithName:[style valueForKey:@"NewsFontFamilyBold"] size:10]];
        [authorLabel_ setTextColor:[UIColor colorWithHexString:[style valueForKey:@"NewsSecondaryColor"]]];		        
        [authorLabel_ setShadowColor:[UIColor colorWithHexString:[style valueForKey:@"NewsShadowColor"]]];
		[authorLabel_ setShadowOffset:CGSizeMake(0, 2)];
		[authorLabel_ setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:authorLabel_];
        
		// Initialization of the newss description		
		dateLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(100, 55, 90, 12)];
        [dateLabel_ setFont:[UIFont fontWithName:[style valueForKey:@"NewsFontFamily"] size:10]];
        [dateLabel_ setTextColor:[UIColor colorWithHexString:[style valueForKey:@"NewsExtraColor"]]];				         
        [dateLabel_ setShadowColor:[UIColor colorWithHexString:[style valueForKey:@"NewsShadowColor"]]];
		[dateLabel_ setShadowOffset:CGSizeMake(0, 2)];
		[dateLabel_ setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:dateLabel_];
		
		[self setSelectionStyle:UITableViewCellSelectionStyleGray];
		
		[self setAccessoryType:UITableViewCellAccessoryNone];
		UIImageView *disclousureImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MCANews.bundle/NewsCellDisclosure.png"]];
		[disclousureImage setFrame:CGRectMake(304, 30, 8, 14)];
		[self.contentView addSubview:disclousureImage];
		[disclousureImage release];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[image_ release];
	[titleLabel_ release];
	[authorLabel_ release];
	[dateLabel_ release];
	[dateFormatter_ release];
    [super dealloc];
}

#pragma mark class methods

//Method that allows configure the cell information. The objet that it receives is an Item with all the information available about the news: author, title, image...
-(void) configureCell:(MVYFeedItem *)item{
    NSString *image = [item.thumbnails lastObject];
    if ([image length]<=0){
        image = [item.images lastObject];
    }
	if ([image length]>0){
		[image_ setAppearEfect:YES];
		[image_ loadImageFromURL:[NSURL URLWithString:image] loadingImage:[UIImage imageNamed:@"MCANews.bundle/NewsImagePlaceholder.png"]];
	} else {
		[image_ setAppearEfect:NO];
		[image_ setImage:[UIImage imageNamed:@"MCANews.bundle/NewsNoImage.png"]];
	}
    
	[titleLabel_ setText:item.title];
	[authorLabel_ setText:item.author];
	CGSize size = [authorLabel_.text sizeWithFont:authorLabel_.font constrainedToSize:CGSizeMake(120, authorLabel_.frame.size.height)]; 
	[authorLabel_ setFrame:CGRectMake(authorLabel_.frame.origin.x, authorLabel_.frame.origin.y, size.width, authorLabel_.frame.size.height)];
	[dateLabel_ setText:[dateFormatter_ stringFromDate:item.date]];
	[dateLabel_ setFrame:CGRectMake((size.width+authorLabel_.frame.origin.x), dateLabel_.frame.origin.y, dateLabel_.frame.size.width, dateLabel_.frame.size.height)];
}

@end
