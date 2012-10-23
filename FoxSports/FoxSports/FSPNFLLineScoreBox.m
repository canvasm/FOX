//
//  FSPNFLLineScoreBox.m
//  FoxSports
//
//  Created by Joshua Dubey on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLLineScoreBox.h"
#import "FSPGameSegmentView.h"
#import "UIFont+FSPExtensions.h"

@implementation FSPNFLLineScoreBox

@synthesize totalScoresView;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		
		//Add total scores view manually
		self.totalScoresView = [[FSPGameSegmentView alloc] initWithFrame:CGRectZero];
		[self.totalScoresView setXPosition:CGRectGetMaxX(self.scoresContainerView.frame)];
		self.totalScoresView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
		UIFont *totalScoresFont = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:15.0f];
        [self.totalScoresView setScoreLabelFonts:totalScoresFont];
        
		self.totalScoresView.gameSegmentLabel.text = @"TOTAL";
		self.totalScoresView.gameSegmentLabel.accessibilityIdentifier = @"totalScoreLabel";
		[self addSubview:self.totalScoresView];
		
		self.totalScoresView.homeTeamScoreLabel.accessibilityIdentifier = @"totalHomeTeamScore";
		self.totalScoresView.awayTeamScoreLabel.accessibilityIdentifier = @"totalAwayTeamScore";
	}
	return self;
}

- (void)resetGameSegments
{
	[super resetGameSegments];
	
    // This character is actually made with the keyboard combination "alt-dash".  It 
    // produces a longer dash than usual.
	self.totalScoresView.homeTeamScoreLabel.text = @"–";
    self.totalScoresView.awayTeamScoreLabel.text = @"–";
    self.totalScoresView.homeTeamScoreLabel.accessibilityLabel = self.totalScoresView.homeTeamScoreLabel.text;
    self.totalScoresView.awayTeamScoreLabel.accessibilityLabel = self.totalScoresView.awayTeamScoreLabel.text;
}

@end
