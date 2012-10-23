//
//  FSPMLBGameTraxPitchCountCell.m
//  FoxSports
//
//  Created by Jeremy Eccles on 10/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBGameTraxPitchCountCell.h"
#import "UIFont+FSPExtensions.h"

@implementation FSPMLBGameTraxPitchCountCell

@synthesize callLabel, pitchLabel, speedLabel, countImageView;

- (id) init {
	NSArray *topLevelObjs = nil;

	topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"FSPMLBGameTraxPitchCountCell" owner:self options:nil];
	if (topLevelObjs == nil)
	{
		NSLog(@"Error! Could not load FSPMLBGameTraxPitchCountCell.xib file.\n");
		return nil;

	}

	self = [topLevelObjs objectAtIndex:0];

	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    callLabel.lineHeight = 14;

    [callLabel setFont:[UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12]];
    [pitchLabel setFont:[UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12]];
    [speedLabel setFont:[UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12]];
}

@end
