//
//  FSPNBAFullSchedulePastCell.m
//  FoxSports
//
//  Created by Matthew Fay on 2/14/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNBALeagueScheduleCell.h"
#import "FSPBasketballGame.h"
#import "FSPTeam.h"
#import "FSPScheduleNBAGame.h"
#import "UIFont+FSPExtensions.h"

static CGFloat const FSPWinningPlayerLeftOriginX = 292.0;
static CGFloat const FSPWinningPlayerRightOriginX = 470.0;

@implementation FSPNBALeagueScheduleCell

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPNBALeagueScheduleCell" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.col0Label.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
}

- (void)populateWithGame:(FSPScheduleNBAGame *)game;
{
	[super populateWithGame:game];
	
	if (!self.isFuture) {
        BOOL homeWon = [game.homeTeamScore intValue] > [game.awayTeamScore intValue];
        if (homeWon)
            self.col0Label.text = [NSString stringWithFormat:@"@ %@ %@, %@ %@", game.homeTeamName, game.homeTeamScore, game.awayTeamName, game.awayTeamScore];
        else
            self.col0Label.text = [NSString stringWithFormat:@"%@ %@ @ %@ %@", game.awayTeamName, game.awayTeamScore, game.homeTeamName, game.homeTeamScore];
        
        NSString *awayPlayer;
        NSString *homePlayer;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            awayPlayer = [NSString stringWithFormat:@"%@ %@ %@ pts", game.awayTeamAbbreviation, game.highPointsAwayPlayerName, game.highPointsAwayPlayerPoints];
            homePlayer = [NSString stringWithFormat:@"%@ %@ %@ pts", game.homeTeamAbbreviation, game.highPointsHomePlayerName, game.highPointsHomePlayerPoints];
            if (game.highPointsHomePlayerName)
                self.col1Label.text = homeWon ? homePlayer : awayPlayer;
            if (game.highPointsAwayPlayerName)
                self.col2Label.text = homeWon ? awayPlayer : homePlayer;
        } else {
            awayPlayer = [NSString stringWithFormat:@"%@ %@ pts", game.highPointsAwayPlayerName, game.highPointsAwayPlayerPoints];
            homePlayer = [NSString stringWithFormat:@"%@ %@ pts", game.highPointsHomePlayerName, game.highPointsHomePlayerPoints];
            self.col3Label.text = [NSString stringWithFormat:@"Top Scorers: %@, %@", homeWon ? homePlayer : awayPlayer, homeWon ? awayPlayer : homePlayer];
            self.col1Label.hidden = YES;
            self.col2Label.hidden = YES;
        }

    } else {
        self.col1Label.hidden = NO;
        self.col2Label.hidden = NO;
        self.col3Label.hidden = YES;
        self.col1Label.text = [self startDateStringFromEvent:game];
        self.col2Label.text = game.channelDisplayName;
    }
    
}

- (void)updateSubviewPositions
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [super updateSubviewPositions];
        if (!self.isFuture) {
            //Lay out the cell for only 2 labels
            CGRect topPlayerLeftFrame = self.col1Label.frame;
            topPlayerLeftFrame.origin.x = FSPWinningPlayerLeftOriginX;
            self.col1Label.frame = topPlayerLeftFrame;
            
            CGRect topPlayerRightFrame = self.col2Label.frame;
            topPlayerRightFrame.origin.x = FSPWinningPlayerRightOriginX;
            self.col2Label.frame = topPlayerRightFrame;
            
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
