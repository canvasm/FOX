//
//  FSPNBAMatchupView.m
//  FoxSports
//
//  Created by Laura Savino on 4/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNBAMatchupView.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPTeamRecord.h"
#import "FSPGameDetailTeamHeader.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPGameDetailSectionDrawing.h"
#import "FSPGameDetailSectionHeader.h"

@interface FSPNBAMatchupView ()

@property(nonatomic, weak) IBOutlet UILabel *homeTeamWinLossLabel;
@property(nonatomic, weak) IBOutlet UILabel *awayTeamWinLossLabel;
@property(nonatomic, weak) IBOutlet UILabel *homeTeamPPGLabel;
@property(nonatomic, weak) IBOutlet UILabel *awayTeamPPGLabel;
@property(nonatomic, weak) IBOutlet UILabel *homeTeamRPGLabel;
@property(nonatomic, weak) IBOutlet UILabel *awayTeamRPGLabel;
@property(nonatomic, weak) IBOutlet UILabel *homeTeamTOGLabel;
@property(nonatomic, weak) IBOutlet UILabel *awayTeamTOGLabel;

@property (weak, nonatomic) IBOutlet FSPGameDetailTeamHeader *homeDetailTeamHeader;
@property (weak, nonatomic) IBOutlet FSPGameDetailTeamHeader *awayDetailTeamHeader;

/**
 * Updates matchup container to contain appropriate accessibility text.
 */
- (void)updateMatchupAccessibilityLabels;

@end

@implementation FSPNBAMatchupView

@synthesize homeTeamWinLossLabel, awayTeamWinLossLabel;
@synthesize homeTeamPPGLabel, awayTeamPPGLabel;
@synthesize homeTeamRPGLabel, awayTeamRPGLabel;
@synthesize homeTeamTOGLabel, awayTeamTOGLabel;
@synthesize matchupTitleLabels = _matchupTitleLabels;
@synthesize matchupValueLabels = _matchupValueLabels;

- (id)init
{
    UINib *matchupNib = [UINib nibWithNibName:@"FSPNBAMatchupView" bundle:nil];
    NSArray *objects = [matchupNib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    self.sectionHeader.highlightLineFlag = @(NO);
    self.sectionHeader.darkLineFlag = @(NO);
    return self;
}

- (void)awakeFromNib
{
    UIFont *matchupTitleFont = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    UIColor *matchupTitleColor = [UIColor whiteColor];
    for (UILabel *label in self.matchupTitleLabels) {
        label.font = matchupTitleFont;
        label.textColor = matchupTitleColor;
    }
        

    UIFont *matchupValueFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14.0];
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

    //If either team does not have an overall record, mark information as incomplete and do not update subviews.
    if(!homeTeam.pointsPerGame || !awayTeam.pointsPerGame) {
        self.informationComplete = NO;
        return;
    } else {
        self.informationComplete = YES;
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self.homeDetailTeamHeader setTeamWithShortNameDisplay:homeTeam teamColor:game.homeTeamColor];
        [self.awayDetailTeamHeader setTeamWithShortNameDisplay:awayTeam teamColor:game.awayTeamColor];
    } else {
        [self.homeDetailTeamHeader setTeam:homeTeam teamColor:game.homeTeamColor];
        [self.awayDetailTeamHeader setTeam:awayTeam teamColor:game.awayTeamColor];
    }

    
    // Calculate which stat is 'better', and give the winning stat a font with name FSPClearFOXGothicHeavyFontName and white font color. In the case of a tie, neither is highlighted
    NSDecimalNumber *homeTeamWins = [NSDecimalNumber decimalNumberWithString:[game.homeTeam.overallRecord.wins description]];
    NSDecimalNumber *homeTeamLosses = [NSDecimalNumber decimalNumberWithString:[game.homeTeam.overallRecord.losses description]];
    NSDecimalNumber *homeTeamAvg = (homeTeamLosses.floatValue != 0 ?
                                    [homeTeamWins decimalNumberByDividingBy:homeTeamLosses] :
                                    [NSDecimalNumber decimalNumberWithString:@"0.0"]);
    NSDecimalNumber *homeTeamPPG = [NSDecimalNumber decimalNumberWithString:game.homeTeam.pointsPerGame];
    NSDecimalNumber *homeTeamRPG = [NSDecimalNumber decimalNumberWithString:game.homeTeam.reboundsPerGame];
    NSDecimalNumber *homeTeamTOG = [NSDecimalNumber decimalNumberWithString:game.homeTeam.turnoversPerGame];
    
    NSDecimalNumber *awayTeamWins = [NSDecimalNumber decimalNumberWithString:[game.awayTeam.overallRecord.wins description]];
    NSDecimalNumber *awayTeamLosses = [NSDecimalNumber decimalNumberWithString:[game.awayTeam.overallRecord.losses description]];
    NSDecimalNumber *awayTeamAvg = (awayTeamLosses.floatValue != 0 ?
                                    [awayTeamWins decimalNumberByDividingBy:awayTeamLosses] :
                                    [NSDecimalNumber decimalNumberWithString:@"0.0"]);
    NSDecimalNumber *awayTeamPPG = [NSDecimalNumber decimalNumberWithString:game.awayTeam.pointsPerGame];
    NSDecimalNumber *awayTeamRPG = [NSDecimalNumber decimalNumberWithString:game.awayTeam.reboundsPerGame];
    NSDecimalNumber *awayTeamTOG = [NSDecimalNumber decimalNumberWithString:game.awayTeam.turnoversPerGame];

    CGFloat pointSize = self.homeTeamWinLossLabel.font.pointSize;
    UIColor *winColor = [UIColor whiteColor];
    UIFont *winFont = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:pointSize];

    if ([awayTeamAvg compare:homeTeamAvg] == NSOrderedAscending) {
        self.homeTeamWinLossLabel.font = winFont;
        self.homeTeamWinLossLabel.textColor = winColor;
    }
    else if ([awayTeamAvg compare:homeTeamAvg] == NSOrderedDescending) {
        self.awayTeamWinLossLabel.font = winFont;
        self.awayTeamWinLossLabel.textColor = winColor;
    }

    if ([awayTeamPPG compare:homeTeamPPG] == NSOrderedAscending) {
        self.homeTeamPPGLabel.font = winFont;
        self.homeTeamPPGLabel.textColor = winColor;
    }
    else if ([awayTeamPPG compare:homeTeamPPG] == NSOrderedDescending) {
        self.awayTeamPPGLabel.font = winFont;
        self.awayTeamPPGLabel.textColor = winColor;
    }

    
    if ([awayTeamRPG compare:homeTeamRPG] == NSOrderedAscending) {
        self.homeTeamRPGLabel.font = winFont;
        self.homeTeamRPGLabel.textColor = winColor;
    }
    else if ([awayTeamRPG compare:homeTeamRPG] == NSOrderedDescending) {
        self.awayTeamRPGLabel.font = winFont;
        self.awayTeamRPGLabel.textColor = winColor;
    }
    
    if ([awayTeamTOG compare:homeTeamTOG] == NSOrderedDescending) {
        self.homeTeamTOGLabel.font = winFont;
        self.homeTeamTOGLabel.textColor = winColor;
    }
    else if ([awayTeamTOG compare:homeTeamTOG] == NSOrderedAscending) {
        self.awayTeamTOGLabel.font = winFont;
        self.awayTeamTOGLabel.textColor = winColor;
    }
    
    
    self.homeTeamWinLossLabel.text = game.homeTeam.overallRecord.winLossRecordString;
    self.awayTeamWinLossLabel.text = game.awayTeam.overallRecord.winLossRecordString;
    
    self.homeTeamPPGLabel.text = game.homeTeam.pointsPerGame;
    self.awayTeamPPGLabel.text = game.awayTeam.pointsPerGame;
    
    self.homeTeamRPGLabel.text = game.homeTeam.reboundsPerGame;
    self.awayTeamRPGLabel.text = game.awayTeam.reboundsPerGame;
    
    self.homeTeamTOGLabel.text = game.homeTeam.turnoversPerGame;
    self.awayTeamTOGLabel.text = game.awayTeam.turnoversPerGame;
    
    [self updateMatchupAccessibilityLabels];
}

- (void)updateMatchupAccessibilityLabels;
{    
    // Matchup accessibility identifiers -- used for automated QA testing
    // TODO: move this to someplace where we only need to set it once
    self.accessibilityIdentifier = @"pregameMatchup";    
    self.homeTeamWinLossLabel.accessibilityIdentifier = @"homeRecord";
    self.awayTeamWinLossLabel.accessibilityIdentifier = @"awayRecord";
    self.homeTeamPPGLabel.accessibilityIdentifier = @"homePPG";
    self.awayTeamPPGLabel.accessibilityIdentifier = @"awayPPG";
    self.homeTeamRPGLabel.accessibilityIdentifier = @"homeRPG";
    self.awayTeamRPGLabel.accessibilityIdentifier = @"awayRPG";
    self.homeTeamTOGLabel.accessibilityIdentifier = @"homeTOG";
    self.awayTeamTOGLabel.accessibilityIdentifier = @"awayTOG";
    
    // Dynamic accessibility data for each matchup entry -- could be grouped into containers
    self.homeTeamWinLossLabel.accessibilityLabel = self.homeTeamWinLossLabel.text;
    self.awayTeamWinLossLabel.accessibilityLabel = self.awayTeamWinLossLabel.text;
    self.homeTeamPPGLabel.accessibilityLabel = self.homeTeamPPGLabel.text;
    self.awayTeamPPGLabel.accessibilityLabel = self.awayTeamPPGLabel.text;
    self.homeTeamRPGLabel.accessibilityLabel = self.homeTeamRPGLabel.text;
    self.awayTeamRPGLabel.accessibilityLabel = self.awayTeamRPGLabel.text;
    self.homeTeamTOGLabel.accessibilityLabel = self.homeTeamTOGLabel.text;
    self.awayTeamTOGLabel.accessibilityLabel = self.awayTeamTOGLabel.text;
}

@end
