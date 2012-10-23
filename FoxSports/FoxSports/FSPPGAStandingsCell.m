//
//  FSPNFLStandingsCell.m
//  FoxSports

#import "FSPPGAStandingsCell.h"
#import "FSPImageFetcher.h"
#import "UIColor+FSPExtensions.h"

@interface FSPPGAStandingsCell ()
@property (nonatomic, assign) IBOutlet UIImageView *countryView;
@end

@implementation FSPPGAStandingsCell

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self prepareForReuse];
	self.rankLabel.textColor = [UIColor fsp_colorWithIntegralRed:49 green:99 blue:151 alpha:1.0];;
}


- (void)setRank:(NSNumber *)rank {
	self.rankLabel.text = [rank stringValue];
}

- (void)setPlayerName:(NSString *)name {
	self.teamNameLabel.text = name;
}

- (void)setDetailText:(NSString *)text {
	self.winsLabel.text = text;
}

- (void)loadImageFromURL:(NSURL *)URL
{
	[FSPImageFetcher.sharedFetcher fetchImageForURL:URL
									   withCallback:^(UIImage *image) {
										   CGRect imageFrame = self.countryView.frame;
										   if (image) {
											   self.countryView.hidden = NO;
											   self.countryView.image = image;
											   
											   imageFrame.size.width = 40.0;

										   } else {
											   self.countryView.hidden = YES;
											   self.countryView.image = nil;
											   
											   imageFrame.size.width = 0;
										   }
										   self.countryView.frame = imageFrame;

										   CGRect frame = self.teamNameLabel.frame;
                                           CGFloat teamNameMargin = 10.0;
										   frame.origin.x = CGRectGetMaxX(imageFrame) + teamNameMargin;
										   frame.size.width = self.winsLabel.frame.origin.x - frame.origin.x - 16;
										   self.teamNameLabel.frame = frame;
	}];
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	
	CGRect imageFrame = self.countryView.frame;
	self.countryView.hidden = YES;
	self.countryView.image = nil;
		
	imageFrame.size.width = 0;

	self.countryView.frame = imageFrame;
	
	CGRect frame = self.teamNameLabel.frame;
	frame.origin.x = CGRectGetMaxX(imageFrame);
	frame.size.width = self.winsLabel.frame.origin.x - frame.origin.x - 16;
	self.teamNameLabel.frame = frame;
}

@end
