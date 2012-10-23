//
//  FSPNewsStoryCell.m
//  FoxSports
//
//  Created by greay on 5/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNewsStoryCell.h"
#import "AFNetworking.h"
#import "FSPLabel.h"
#import "FSPNewsHeadline.h"
#import "FSPImageFetcher.h"
#import "FSPVideo.h"

#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@implementation FSPNewsStoryCell

@synthesize storyLabel;
@synthesize thumbnailView;
@synthesize containerView;

- (void)awakeFromNib
{
    self.storyLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:16];
    self.storyLabel.highlightedTextColor = [UIColor whiteColor];
    self.storyLabel.textColor = [UIColor colorWithRed:0.24 green:0.39 blue:0.54 alpha:1.0];
    self.storyLabel.backgroundColor = [UIColor clearColor];
    self.storyLabel.normalTextShadowColor = [UIColor chipTextShadowUnselectedColor];
    self.storyLabel.highlightedTextShadowColor = [UIColor chipTextShadowSelectedColor];
    
    self.containerView.layer.cornerRadius = 1;
    self.containerView.layer.masksToBounds = YES;
	self.containerView.hidden = NO;

	self.thumbnailView.layer.cornerRadius = 5;
    self.thumbnailView.layer.masksToBounds = YES;
	
	CGRect storyFrame = self.storyLabel.frame;
    storyFrame.size.width = 181;
    self.storyLabel.frame = storyFrame;
}

- (void)prepareForReuse;
{
	self.storyLabel.text = @"";
	[self.thumbnailView af_cancelImageRequestOperation];
	self.thumbnailView.image = nil;
}

- (void)populateWithHeadline:(FSPNewsHeadline *)headline
{
	self.storyLabel.text = headline.title;
    self.thumbnailView.image = [UIImage imageNamed:@"default_news"];
    if (headline.imageURL && ![headline.imageURL isEqualToString:@""]) {
        [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:headline.imageURL]
                                           withCallback:^(UIImage *image) {
                                               if (image) {
                                                   self.thumbnailView.image = image;
                                               }
                                           }];
    }

}

- (void)populateWithVideo:(FSPVideo *)video
{
	self.storyLabel.text = video.title;
    self.thumbnailView.image = [UIImage imageNamed:@"default_news"];
    if (video.imageURL && ![video.imageURL isEqualToString:@""]) {
        [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:video.imageURL]
                                           withCallback:^(UIImage *image) {
                                               if (image) {
                                                   self.thumbnailView.image = image;
                                               } 
                                           }];
    }
}

@end
