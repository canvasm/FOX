//
//  FSPTennisScoresView.m
//  FoxSports
//
//  Created by greay on 9/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisScoresView.h"
#import "FSPTennisMatchSegment.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"

@implementation FSPTennisScoresView

- (void)awakeFromNib
{
	self.layer.borderColor = [UIColor fsp_lightBlueColor].CGColor;
	self.layer.borderWidth = 1.0;
	
	NSMutableArray *scoreLabels1 = [NSMutableArray array];
	NSMutableArray *tieLabels1 = [NSMutableArray array];
	NSMutableArray *scoreLabels2 = [NSMutableArray array];
	NSMutableArray *tieLabels2 = [NSMutableArray array];
	
	UILabel *label;
	for (NSUInteger i = 0; i < 5; i++) {
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
		label.textAlignment = UITextAlignmentRight;
		[scoreLabels1 addObject:label];
		[self addSubview:label];
//		label.layer.borderWidth = 1.0; label.layer.borderColor = [UIColor redColor].CGColor;

		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
		label.textAlignment = UITextAlignmentRight;
		[scoreLabels2 addObject:label];
		[self addSubview:label];
//		label.layer.borderWidth = 1.0; label.layer.borderColor = [UIColor yellowColor].CGColor;

		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
		label.textAlignment = UITextAlignmentLeft;
		[tieLabels1 addObject:label];
		[self addSubview:label];
//		label.layer.borderWidth = 1.0; label.layer.borderColor = [UIColor greenColor].CGColor;

		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
		label.textAlignment = UITextAlignmentLeft;
		[tieLabels2 addObject:label];
		[self addSubview:label];
//		label.layer.borderWidth = 1.0; label.layer.borderColor = [UIColor cyanColor].CGColor;
	}
	
	self.topScoreLabels = scoreLabels1;
	self.bottomScoreLabels = scoreLabels2;
	self.topTieLabels = tieLabels1;
	self.bottomTieLabels = tieLabels2;
}

- (void)setScores:(NSSet *)scores
{
	_scores = scores;
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"segmentNumber" ascending:YES];
	NSArray *orderedSegments = [self.scores sortedArrayUsingDescriptors:@[sort]];
	
	UIFont *winnerFont = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:14];
	UIFont *loserFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
	UIColor *winnerColor = [UIColor whiteColor];
	UIColor *loserColor = [UIColor fsp_lightBlueColor];

	for (NSUInteger i = 0; i < 5; i++) {
		UILabel *topScoreLabel = [self.topScoreLabels objectAtIndex:i];
		UILabel *bottomScoreLabel = [self.bottomScoreLabels objectAtIndex:i];
		UILabel *topTieLabel = [self.topTieLabels objectAtIndex:i];
		UILabel *bottomTieLabel = [self.bottomTieLabels objectAtIndex:i];

		if (i < orderedSegments.count) {
			FSPTennisMatchSegment *score = [orderedSegments objectAtIndex:i];
			
			topScoreLabel.text = [score.score1 stringValue];
			bottomScoreLabel.text = [score.score2 stringValue];
			topTieLabel.text = ([score.tie1 integerValue] > 0) ? [score.tie1 stringValue] : @"";
			bottomTieLabel.text = ([score.tie2 integerValue] > 0) ? [score.tie2 stringValue] : @"";

			if ([score.score1 integerValue] > [score.score2 integerValue] ||
				([score.score1 integerValue] == [score.score2 integerValue] && [score.tie1 integerValue] > [score.tie2 integerValue]))
			{
				topScoreLabel.font = winnerFont;
				topScoreLabel.textColor = winnerColor;
				topTieLabel.font = winnerFont;
				topTieLabel.textColor = winnerColor;

				bottomScoreLabel.font = loserFont;
				bottomScoreLabel.textColor = loserColor;
				bottomTieLabel.font = loserFont;
				bottomTieLabel.textColor = loserColor;
			} else if ([score.score1 integerValue] < [score.score2 integerValue] ||
					   ([score.score1 integerValue] == [score.score2 integerValue] && [score.tie1 integerValue] < [score.tie2 integerValue]))
			{
				topScoreLabel.font = loserFont;
				topScoreLabel.textColor = loserColor;
				topTieLabel.font = loserFont;
				topTieLabel.textColor = loserColor;
				
				bottomScoreLabel.font = winnerFont;
				bottomScoreLabel.textColor = winnerColor;
				bottomTieLabel.font = winnerFont;
				bottomTieLabel.textColor = winnerColor;
			} else {
				topScoreLabel.font = loserFont;
				topScoreLabel.textColor = loserColor;
				topTieLabel.font = loserFont;
				topTieLabel.textColor = loserColor;
				
				bottomScoreLabel.font = loserFont;
				bottomScoreLabel.textColor = loserColor;
				bottomTieLabel.font = loserFont;
				bottomTieLabel.textColor = loserColor;
			}
			
		} else {
			topScoreLabel.text = @"";
			bottomScoreLabel.text = @"";
			topTieLabel.text = @"";
			bottomTieLabel.text = @"";
		}
	}
}

- (void)layoutSubviews
{
	CGRect contentRect = CGRectInset(self.bounds, 6, 0);
	CGFloat width = contentRect.size.width / 5;
	CGFloat height = contentRect.size.height / 2;
	for (NSUInteger i = 0; i < 5; i++) {
		CGFloat x = contentRect.origin.x + i * width;
		[(UILabel *)[self.topScoreLabels objectAtIndex:i] setFrame:CGRectMake(x, 4, width / 2 - 4, height)];
		[(UILabel *)[self.bottomScoreLabels objectAtIndex:i] setFrame:CGRectMake(x, height + 4, width / 2 - 4, height)];

		[(UILabel *)[self.topTieLabels objectAtIndex:i] setFrame:CGRectMake(x + width / 2 - 4, 0, width / 2 + 6, height)];
		[(UILabel *)[self.bottomTieLabels objectAtIndex:i] setFrame:CGRectMake(x + width / 2- 4, height, width / 2 + 6, height)];
	}
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);
    [[UIColor fsp_lightBlueColor] set];
    CGContextSetLineWidth(context, 1);
	CGFloat y = floorf(self.bounds.size.height / 2);
    CGPoint segments[] = { CGPointMake(0.0, y), CGPointMake(self.bounds.size.width, y) };
    CGContextStrokeLineSegments(context, segments, 1);
    CGContextRestoreGState(context);
}

@end
