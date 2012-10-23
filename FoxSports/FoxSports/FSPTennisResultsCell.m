//
//  FSPTennisResultsCell.m
//  FoxSports
//
//  Created by greay on 9/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisResultsCell.h"
#import "FSPTennisScoresView.h"
#import "FSPTennisMatch.h"
#import "FSPTennisPlayer.h"

#import "FSPImageFetcher.h"

#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@interface FSPTennisResultsCell ()

@property (nonatomic, assign) IBOutlet UILabel *competitor1Label;
@property (nonatomic, assign) IBOutlet UILabel *competitor2Label;
@property (nonatomic, assign) IBOutlet UIImageView *competitor1ImageView;
@property (nonatomic, assign) IBOutlet UIImageView *competitor2ImageView;
@property (nonatomic, assign) IBOutlet FSPTennisScoresView *scoresView;

@end

@implementation FSPTennisResultsCell

- (void)populateWithMatch:(FSPTennisMatch *)match
{
	self.competitor1Label.text = match.competitor1.firstName;
	self.competitor2Label.text = match.competitor2.firstName;
	[self loadImageFromURL:[NSURL URLWithString:match.competitor1.photoURL] forImageView:self.competitor1ImageView];
	[self loadImageFromURL:[NSURL URLWithString:match.competitor2.photoURL] forImageView:self.competitor2ImageView];
	
	[self.scoresView setScores:match.segments];
	 
	self.competitor1Label.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14];
	self.competitor1Label.textColor = [UIColor whiteColor];
	self.competitor2Label.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14];
	self.competitor2Label.textColor = [UIColor whiteColor];

}

- (void)loadImageFromURL:(NSURL *)URL forImageView:(UIImageView *)imageView
{
	[FSPImageFetcher.sharedFetcher fetchImageForURL:URL
									   withCallback:^(UIImage *image) {
										   if (image) {
											   imageView.hidden = NO;
											   imageView.image = image;
										   } else {
											   imageView.hidden = YES;
											   imageView.image = nil;
										   }
									   }];
}

@end
