//
//  FSPHockeyMatchupView.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/30/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPHockeyMatchupView.h"
#import "FSPGameDetailSectionHeader.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPTeamRecord.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPGameDetailTeamHeader.h"

@interface FSPHockeyMatchupView ()

@property (weak, nonatomic) IBOutlet UILabel *awayPointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayWinLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayGoalsPerGameLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayGoalsAllowedLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayPowerPlayLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayPenaltyKillLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayShotsLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayShotsAgainstLabel;
@property (weak, nonatomic) IBOutlet UILabel *homePointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeWinLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeGoalsPerGameLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeGoalsAllowedLabel;
@property (weak, nonatomic) IBOutlet UILabel *homePowerPlayLabel;
@property (weak, nonatomic) IBOutlet UILabel *homePenaltyKillLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeShotsLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeShotsAgainstLabel;


@property (weak, nonatomic) IBOutlet FSPGameDetailTeamHeader *homeDetailTeamHeader;
@property (weak, nonatomic) IBOutlet FSPGameDetailTeamHeader *awayDetailTeamHeader;

@end

@implementation FSPHockeyMatchupView {
    CGFloat fontSize;
}

@synthesize awayPointsLabel;
@synthesize awayWinLabel;
@synthesize awayGoalsPerGameLabel;
@synthesize awayGoalsAllowedLabel;
@synthesize awayPowerPlayLabel;
@synthesize awayPenaltyKillLabel;
@synthesize awayShotsLabel;
@synthesize awayShotsAgainstLabel;
@synthesize homePointsLabel;
@synthesize homeWinLabel;
@synthesize homeGoalsPerGameLabel;
@synthesize homeGoalsAllowedLabel;
@synthesize homePowerPlayLabel;
@synthesize homePenaltyKillLabel;
@synthesize homeShotsLabel;
@synthesize homeShotsAgainstLabel;
@synthesize homeDetailTeamHeader;
@synthesize awayDetailTeamHeader;


- (id)init
{
    UINib *matchupNib = [UINib nibWithNibName:@"FSPHockeyMatchupView" bundle:nil];
    NSArray *objects = [matchupNib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    self.sectionHeader.highlightLineFlag = @(NO);
    self.sectionHeader.darkLineFlag = @(NO);
    return self;
}

- (void)awakeFromNib
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        fontSize = 14.0f;
    } else {
        fontSize = 13.0f;
    }
    
    UIFont *matchupTitleFont = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
    UIColor *matchupTitleColor = [UIColor whiteColor];
    for (UILabel *label in self.matchupTitleLabels) {
        label.font = matchupTitleFont;
        label.textColor = matchupTitleColor;
    }
        
    
    UIFont *matchupValueFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];
    UIColor *matchupValueColor = [UIColor fsp_lightBlueColor];
    for (UILabel *label in self.matchupValueLabels) {
        label.font = matchupValueFont;
        label.textColor = matchupValueColor;
    }
    
    self.homeDetailTeamHeader.teamNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:15.0];
    self.awayDetailTeamHeader.teamNameLabel.font = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:15.0];
    self.homeDetailTeamHeader.teamNameLabel.textColor = [UIColor whiteColor];
    self.awayDetailTeamHeader.teamNameLabel.textColor = [UIColor whiteColor];
    
}


- (void)updateInterfaceWithGame:(FSPGame *)game;
{
    FSPTeam *homeTeam = game.homeTeam;
    FSPTeam *awayTeam = game.awayTeam;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self.homeDetailTeamHeader setTeamWithShortNameDisplay:homeTeam teamColor:game.homeTeamColor];
        [self.awayDetailTeamHeader setTeamWithShortNameDisplay:awayTeam teamColor:game.awayTeamColor];
    } else {
        [self.homeDetailTeamHeader setTeam:homeTeam teamColor:game.homeTeamColor];
        [self.awayDetailTeamHeader setTeam:awayTeam teamColor:game.awayTeamColor];
    }
    
    self.homePointsLabel.text = homeTeam.points;
    self.awayPointsLabel.text = awayTeam.points;
    [self updateLabelFontForStat:self.homePointsLabel Stat:self.awayPointsLabel largerHighlighted:YES];
    
    self.homeWinLabel.text = [NSString stringWithFormat:@"%@%%", homeTeam.winPercent];
    self.awayWinLabel.text = [NSString stringWithFormat:@"%@%%", awayTeam.winPercent];
    [self updateLabelFontForStat:self.homeWinLabel Stat:self.awayWinLabel largerHighlighted:YES];
    
    self.homeGoalsPerGameLabel.text = homeTeam.goalsPerGame;
    self.awayGoalsPerGameLabel.text = awayTeam.goalsPerGame;
    [self updateLabelFontForStat:self.homeGoalsPerGameLabel Stat:self.awayGoalsPerGameLabel largerHighlighted:YES];
    
    self.homeGoalsAllowedLabel.text = homeTeam.goalsAllowedPerGame;
    self.awayGoalsAllowedLabel.text = awayTeam.goalsAllowedPerGame;
    [self updateLabelFontForStat:self.homeGoalsAllowedLabel Stat:self.awayGoalsAllowedLabel largerHighlighted:NO];
    
    self.homePowerPlayLabel.text = [NSString stringWithFormat:@"%@%%", homeTeam.powerPlayPercentage];
    self.awayPowerPlayLabel.text = [NSString stringWithFormat:@"%@%%", awayTeam.powerPlayPercentage];
    [self updateLabelFontForStat:self.homePowerPlayLabel Stat:self.awayPowerPlayLabel largerHighlighted:YES];
    
    self.homePenaltyKillLabel.text = [NSString stringWithFormat:@"%@%%", homeTeam.penaltyKillPercentage];
    self.awayPenaltyKillLabel.text = [NSString stringWithFormat:@"%@%%", awayTeam.penaltyKillPercentage];
    [self updateLabelFontForStat:self.homePenaltyKillLabel Stat:self.awayPenaltyKillLabel largerHighlighted:YES];
    
    self.homeShotsLabel.text = homeTeam.shotsPerGame;
    self.awayShotsLabel.text = awayTeam.shotsPerGame;
    [self updateLabelFontForStat:self.homeShotsLabel Stat:self.awayShotsLabel largerHighlighted:YES];
    
    self.homeShotsAgainstLabel.text = homeTeam.shotsAgainstPerGame;
    self.awayShotsAgainstLabel.text = awayTeam.shotsAgainstPerGame;
    [self updateLabelFontForStat:self.homeShotsAgainstLabel Stat:self.awayShotsAgainstLabel largerHighlighted:NO];
    
    for (UILabel *label in self.matchupValueLabels) {
        if (label.text == nil || [label.text isEqualToString:@"(null)%"]) {
            label.text = @"--";
        }
    }
    
    
}

- (BOOL)updateLabelFontForStat:(UILabel *)firstStat Stat:(UILabel *)secondStat largerHighlighted:(BOOL)larger;
{
    NSString *potentialLargerStatString;
    NSString *potentialSmallerStatString;
    if (larger) {
        potentialLargerStatString = firstStat.text;
        potentialSmallerStatString = secondStat.text;
    } else {
        potentialLargerStatString = secondStat.text;
        potentialSmallerStatString = firstStat.text;
    }
    
    if ([potentialLargerStatString isEqualToString:@""] || [potentialSmallerStatString isEqualToString:@""]) {
        firstStat.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];
        firstStat.textColor = [UIColor fsp_lightBlueColor];
        secondStat.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];
        secondStat.textColor = [UIColor fsp_lightBlueColor];
        return NO;
    }
    
    if (potentialLargerStatString.floatValue > potentialSmallerStatString.floatValue) {
        firstStat.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
        firstStat.textColor = [UIColor whiteColor];
        secondStat.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];
        secondStat.textColor = [UIColor fsp_lightBlueColor];
    } else if (potentialLargerStatString.floatValue < potentialSmallerStatString.floatValue) {
        secondStat.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
        secondStat.textColor = [UIColor whiteColor];
        firstStat.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];
        firstStat.textColor = [UIColor fsp_lightBlueColor];
    }
    return YES;
}

@end
