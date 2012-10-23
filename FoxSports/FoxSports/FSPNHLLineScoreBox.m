//
//  FSPNHLLineScoreBox.m
//  FoxSports
//
//  Created by Ryan McPherson on 8/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNHLLineScoreBox.h"
#import "FSPGameSegmentView.h"
#import "UIFont+FSPExtensions.h"

@implementation FSPNHLLineScoreBox

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

- (NSString *)displayNameForGameSegment:(NSUInteger)segment;
{
    if(segment > 3) return @"OT";
        else return [NSString stringWithFormat:@"%i", segment];
}


@end
