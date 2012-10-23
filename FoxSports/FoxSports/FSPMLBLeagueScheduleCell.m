//
//  FSPMLBLeagueScheduleCell.m
//  FoxSports
//
//  Created by Matthew Fay on 2/14/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBLeagueScheduleCell.h"
#import "FSPBaseballGame.h"
#import "FSPTeam.h"
#import "FSPScheduleMLBGame.h"
#import "NSDate+FSPExtensions.h"


@implementation FSPMLBLeagueScheduleCell

- (void)populateWithGame:(FSPScheduleMLBGame *)game;
{
	[super populateWithGame:game];
	
	if (!self.isFuture) {
		self.col0Label.text = [NSString stringWithFormat:@"%@ %@ @ %@ %@", game.awayTeamName, game.awayTeamScore, game.homeTeamName, game.homeTeamScore];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.col1Label.text = [NSString stringWithFormat:@"%@", game.winningPlayer ? game.winningPlayer : @""];
			self.col2Label.text = [NSString stringWithFormat:@"%@", game.losingPlayer ? game.losingPlayer : @""];
			self.col3Label.text = [NSString stringWithFormat:@"%@", game.savingPlayer ? game.savingPlayer : @""]; 
		} else {
			self.col1Label.text = [NSString stringWithFormat:@"Win: %@ Loss: %@ Save: %@", game.winningPlayer ? game.winningPlayer : @"–", game.losingPlayer ? game.losingPlayer : @"–", game.savingPlayer ? game.savingPlayer : @"–"];
			self.col2Label.hidden = YES;
			self.col3Label.hidden = YES;
		}
    }
    
}


#pragma mark - Accessibility
- (BOOL)isAccessibilityElement;
{
    return YES;
}

- (NSString *)accessibilityLabel;
{
    NSString *label;
    if (self.isFuture) {
        label = [NSString stringWithFormat:@"%@, on %@, at %@", self.col0Label.text, self.col1Label.text, self.col2Label.text];
    } else {
        label = [NSString stringWithFormat:@"%@, winning team high scorer %@, losing team high scorer %@", self.col0Label.text, self.col1Label.text, self.col2Label.text];
    }
    return label;
}

@end
