//
//  FSPVideoDetailViewController.m
//  FoxSports
//
//  Created by greay on 8/14/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPVideoDetailViewController.h"
#import "FSPVideo.h"
#import "FSPVideoPlayerViewController.h"

#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@interface FSPVideoDetailViewController ()

@property (nonatomic, weak) IBOutlet UIView *videoView;
@property (nonatomic, weak) IBOutlet UIView *detailView;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *ratingLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, strong) FSPVideoPlayerViewController *videoController;

@end

@implementation FSPVideoDetailViewController

- (id)initWithVideo:(FSPVideo *)video
{
	self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if (self) {
		self.video = video;
	}
	return self;
}

- (void)viewDidLoad
{
	self.titleLabel.textColor = [UIColor whiteColor];
	self.ratingLabel.textColor = [UIColor whiteColor];
	self.subtitleLabel.textColor = [UIColor fsp_mediumBlueColor];
	self.descriptionLabel.textColor = [UIColor fsp_mediumBlueColor];
	
	self.titleLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:22];
	self.ratingLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14];
	self.subtitleLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
	self.descriptionLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
	
	self.detailView.backgroundColor = [UIColor clearColor];
	self.videoView.backgroundColor = [UIColor blackColor];
	
	self.ratingLabel.hidden = YES;
	self.subtitleLabel.hidden = YES;
	
	[self layoutViews];
}

- (void)setVideo:(FSPVideo *)video
{
	_video = video;
	self.titleLabel.text = video.title;
	self.descriptionLabel.text = video.desc;
//	self.ratingLabel.text = video.rating;
//	self.subtitleLabel.text = video.subtitle;
	self.ratingLabel.text = nil;
	self.subtitleLabel.text = nil;
	
	[self.videoController.view removeFromSuperview];
	self.videoController = [[FSPVideoPlayerViewController alloc] initWithURL:video.videoURL];
	[self.videoView addSubview:self.videoController.view];
	self.videoController.view.frame = self.videoView.bounds;
	
	[self layoutViews];
}

- (void)layoutViews
{
	// adjust the video frame to the size of the view, maintaining aspect ratio
	CGSize videoSize = CGSizeMake([self.video.width floatValue], [self.video.height floatValue]);
	CGSize adjustedSize = CGSizeMake(self.view.bounds.size.width, videoSize.height * (self.view.bounds.size.width / videoSize.width));
	
	CGRect videoRect, detailRect;
	CGRectDivide(self.view.bounds, &videoRect, &detailRect, adjustedSize.height, CGRectMinYEdge);
	self.videoView.frame = videoRect;
	self.detailView.frame = detailRect;
	
	
	CGRect titleRect, subtitleRect, ratingRect, descriptionRect;
	
	// adjust the title frame
	titleRect = CGRectMake(10, 10, self.view.bounds.size.width - 20, self.titleLabel.bounds.size.height);
	
	CGFloat ratingWidth = 50;
	if (self.ratingLabel.text.length == 0) {
		ratingWidth = 0;
	}
	CGRectDivide(titleRect, &ratingRect, &titleRect, ratingWidth, CGRectMaxXEdge);
	self.ratingLabel.frame = ratingRect;
	
	CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(titleRect.size.width, 999)];
	titleRect.size.height = titleSize.height;
	self.titleLabel.frame = titleRect;
	
	CGFloat descriptionOffset = CGRectGetMaxY(titleRect);
	if (self.subtitleLabel.text.length > 0) {
		subtitleRect = self.subtitleLabel.frame;
		subtitleRect.origin = CGPointMake(subtitleRect.origin.y, descriptionOffset);
		self.subtitleLabel.frame = subtitleRect;
		descriptionOffset = CGRectGetMaxY(subtitleRect);
	}
	
	CGRectDivide(self.detailView.bounds, &detailRect, &descriptionRect, descriptionOffset, CGRectMinYEdge);
	descriptionRect = CGRectInset(descriptionRect, 10, 5);
	CGSize descriptionSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:descriptionRect.size];
	descriptionRect.size = descriptionSize;
	self.descriptionLabel.frame = descriptionRect;
	
	[self.view setNeedsLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
	self.titleLabel.text = self.video.title;
	self.descriptionLabel.text = self.video.desc;
//	self.ratingLabel.text = video.rating;
//	self.subtitleLabel.text = video.subtitle;

	
	[self layoutViews];
}

@end
