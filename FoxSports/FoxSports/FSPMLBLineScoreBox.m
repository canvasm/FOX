//
//  FSPMLBLineScoreBox.m
//  FoxSports
//
//  Created by greay on 4/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBLineScoreBox.h"
#import "FSPGameSegmentView.h"
#import "UIFont+FSPExtensions.h"

@implementation FSPMLBLineScoreBox

@synthesize totalRunsView, totalHitsView, totalErrorsView;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		
	    self.maxRegularPlayGameSegments = 9;

		//Add total scores view manually
		// runs
		self.totalRunsView = [[FSPGameSegmentView alloc] initWithFrame:CGRectZero];
		[self.totalRunsView setXPosition:CGRectGetMaxX(self.scoresContainerView.frame)];
		self.totalRunsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		
		self.totalRunsView.gameSegmentLabel.text = @"R";
		self.totalRunsView.gameSegmentLabel.accessibilityIdentifier = @"totalRuns";
		[self addSubview:self.totalRunsView];
		
		self.totalRunsView.homeTeamScoreLabel.accessibilityIdentifier = @"totalHomeTeamRuns";
		self.totalRunsView.awayTeamScoreLabel.accessibilityIdentifier = @"totalAwayTeamRuns";
		
		// hits
		self.totalHitsView = [[FSPGameSegmentView alloc] initWithFrame:CGRectZero];
		[self.totalHitsView setXPosition:CGRectGetMaxX(self.scoresContainerView.frame)];
		self.totalHitsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		
		self.totalHitsView.gameSegmentLabel.text = @"H";
		self.totalHitsView.gameSegmentLabel.accessibilityIdentifier = @"totalHits";
		[self addSubview:self.totalHitsView];
		
		self.totalHitsView.homeTeamScoreLabel.accessibilityIdentifier = @"totalHomeTeamHits";
		self.totalHitsView.awayTeamScoreLabel.accessibilityIdentifier = @"totalAwayTeamHits";
		
		// error
		self.totalErrorsView = [[FSPGameSegmentView alloc] initWithFrame:CGRectZero];
		[self.totalErrorsView setXPosition:CGRectGetMaxX(self.scoresContainerView.frame)];
		self.totalErrorsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		
		self.totalErrorsView.gameSegmentLabel.text = @"E";
		self.totalErrorsView.gameSegmentLabel.accessibilityIdentifier = @"totalErrors";
		[self addSubview:self.totalErrorsView];
		
		self.totalErrorsView.homeTeamScoreLabel.accessibilityIdentifier = @"totalHomeTeamErrors";
		self.totalErrorsView.awayTeamScoreLabel.accessibilityIdentifier = @"totalAwayTeamErrors";
		
		UIFont *totalScoresFont = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:15.0f];
        [self.totalRunsView setScoreLabelFonts:totalScoresFont];
        [self.totalHitsView setScoreLabelFonts:totalScoresFont];
        [self.totalErrorsView setScoreLabelFonts:totalScoresFont];

	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGFloat x = CGRectGetMaxX(self.scoresContainerView.frame);
	CGFloat segmentWidth = (self.bounds.size.width - x) / 3;
	self.totalRunsView.frame = CGRectMake(x, 0, segmentWidth, self.bounds.size.height);
	self.totalHitsView.frame = CGRectMake(x + segmentWidth, 0, segmentWidth, self.bounds.size.height);
	self.totalErrorsView.frame = CGRectMake(x + segmentWidth * 2, 0, segmentWidth, self.bounds.size.height);
}

- (NSString *)displayNameForGameSegment:(NSUInteger)segment;
{
    return [NSString stringWithFormat:@"%d", segment];
}

- (void)resetGameSegments
{
	[super resetGameSegments];
	
	self.totalRunsView.homeTeamScoreLabel.text = @"";
    self.totalRunsView.awayTeamScoreLabel.text = @"";
    self.totalRunsView.homeTeamScoreLabel.accessibilityLabel = self.totalRunsView.homeTeamScoreLabel.text;
    self.totalRunsView.awayTeamScoreLabel.accessibilityLabel = self.totalRunsView.awayTeamScoreLabel.text;

	self.totalHitsView.homeTeamScoreLabel.text = @"";
    self.totalHitsView.awayTeamScoreLabel.text = @"";
    self.totalHitsView.homeTeamScoreLabel.accessibilityLabel = self.totalHitsView.homeTeamScoreLabel.text;
    self.totalHitsView.awayTeamScoreLabel.accessibilityLabel = self.totalHitsView.awayTeamScoreLabel.text;

	self.totalErrorsView.homeTeamScoreLabel.text = @"";
    self.totalErrorsView.awayTeamScoreLabel.text = @"";
    self.totalErrorsView.homeTeamScoreLabel.accessibilityLabel = self.totalErrorsView.homeTeamScoreLabel.text;
    self.totalErrorsView.awayTeamScoreLabel.accessibilityLabel = self.totalErrorsView.awayTeamScoreLabel.text;

}


@end
