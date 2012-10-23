//
//  FSPSoccerMatchupView.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/30/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerMatchupView.h"
#import "FSPGameDetailSectionHeader.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPTeamRecord.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPGameDetailTeamHeader.h"

@interface FSPSoccerMatchupView ()

@property (weak, nonatomic) IBOutlet UILabel *leagueNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamesPlayedAway;
@property (weak, nonatomic) IBOutlet UILabel *gamesPlayedHome;
@property (weak, nonatomic) IBOutlet UILabel *goalsHome;
@property (weak, nonatomic) IBOutlet UILabel *goalsAway;
@property (weak, nonatomic) IBOutlet UILabel *goalsAgainstHome;
@property (weak, nonatomic) IBOutlet UILabel *goalsAgainstAway;
@property (weak, nonatomic) IBOutlet UILabel *shotsHome;
@property (weak, nonatomic) IBOutlet UILabel *shotsAway;
@property (weak, nonatomic) IBOutlet UILabel *shotsOnGoalHome;
@property (weak, nonatomic) IBOutlet UILabel *shotsOnGoalAway;
@property (weak, nonatomic) IBOutlet UILabel *yellowCardsHome;
@property (weak, nonatomic) IBOutlet UILabel *yellowCardsAway;
@property (weak, nonatomic) IBOutlet UILabel *redCardsHome;
@property (weak, nonatomic) IBOutlet UILabel *redCardsAway;
@property (weak, nonatomic) IBOutlet UILabel *foulsHome;
@property (weak, nonatomic) IBOutlet UILabel *foulsAway;

@property (weak, nonatomic) IBOutlet FSPGameDetailTeamHeader *homeDetailTeamHeader;
@property (weak, nonatomic) IBOutlet FSPGameDetailTeamHeader *awayDetailTeamHeader;

@end

@implementation FSPSoccerMatchupView {
    CGFloat fontSize;
}

@synthesize leagueNameLabel;
@synthesize venueNameLabel;
@synthesize gamesPlayedAway;
@synthesize gamesPlayedHome;
@synthesize goalsHome;
@synthesize goalsAway;
@synthesize goalsAgainstHome;
@synthesize goalsAgainstAway;
@synthesize shotsHome;
@synthesize shotsAway;
@synthesize shotsOnGoalHome;
@synthesize shotsOnGoalAway;
@synthesize yellowCardsHome;
@synthesize yellowCardsAway;
@synthesize redCardsHome;
@synthesize redCardsAway;
@synthesize foulsHome;
@synthesize foulsAway;
@synthesize homeDetailTeamHeader;
@synthesize awayDetailTeamHeader;


- (id)init
{
    UINib *matchupNib = [UINib nibWithNibName:@"FSPSoccerMatchupView" bundle:nil];
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
    
    self.venueNameLabel.text = game.venue;
    self.leagueNameLabel.text = game.compType;
    
    self.gamesPlayedHome.text = homeTeam.gamesPlayed;
    self.gamesPlayedAway.text = awayTeam.gamesPlayed;
    [self updateLabelFontForStat:self.gamesPlayedHome Stat:self.gamesPlayedAway largerHighlighted:YES];
    
    self.goalsHome.text = homeTeam.goals;
    self.goalsAway.text = awayTeam.goals;
    [self updateLabelFontForStat:self.goalsHome Stat:self.goalsAway largerHighlighted:YES];
    
    self.goalsAgainstHome.text = homeTeam.goalsAgainst;
    self.goalsAgainstAway.text = awayTeam.goalsAgainst;
    [self updateLabelFontForStat:self.goalsAgainstHome Stat:self.goalsAgainstAway largerHighlighted:NO];
    
    self.shotsHome.text = homeTeam.shots;
    self.shotsAway.text = awayTeam.shots;
    [self updateLabelFontForStat:self.shotsHome Stat:self.shotsAway largerHighlighted:YES];
    
    self.shotsOnGoalHome.text = homeTeam.shotsOnGoal;
    self.shotsOnGoalAway.text = awayTeam.shotsOnGoal;
    [self updateLabelFontForStat:self.shotsOnGoalHome Stat:self.shotsOnGoalAway largerHighlighted:YES];
    
    self.yellowCardsHome.text = homeTeam.yellowCards;
    self.yellowCardsAway.text = awayTeam.yellowCards;
    [self updateLabelFontForStat:self.yellowCardsHome Stat:self.yellowCardsAway largerHighlighted:NO];
    
    self.redCardsHome.text = homeTeam.redCards;
    self.redCardsAway.text = awayTeam.redCards;
    [self updateLabelFontForStat:self.redCardsHome Stat:self.redCardsAway largerHighlighted:NO];
    
    self.foulsHome.text = homeTeam.fouls;
    self.foulsAway.text = awayTeam.fouls;
    [self updateLabelFontForStat:self.foulsHome Stat:self.foulsAway largerHighlighted:NO];
    
    for (UILabel *label in self.matchupValueLabels) {
        if (label.text == nil) {
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
