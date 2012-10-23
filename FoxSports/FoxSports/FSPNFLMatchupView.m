//
//  FSPNFLMatchupView.m
//  FoxSports
//
//  Created by Matthew Fay on 7/3/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNFLMatchupView.h"
#import "FSPGameDetailSectionHeader.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "FSPTeamRecord.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"
#import "FSPGameDetailTeamHeader.h"

@interface FSPNFLMatchupView ()


@property (nonatomic, weak) IBOutlet UILabel *homeTeamWinLossLabel;
@property (nonatomic, weak) IBOutlet UILabel *awayTeamWinLossLabel;
@property (nonatomic, weak) IBOutlet UILabel *homeTeamYPGLabel;
@property (nonatomic, weak) IBOutlet UILabel *awayTeamYPGLabel;
@property (nonatomic, weak) IBOutlet UILabel *homeTeamOYPGLabel;
@property (nonatomic, weak) IBOutlet UILabel *awayTeamOYPGLabel;
@property (nonatomic, weak) IBOutlet UILabel *homeTeamTOGLabel;
@property (nonatomic, weak) IBOutlet UILabel *awayTeamTOGLabel;

@property (weak, nonatomic) IBOutlet FSPGameDetailTeamHeader *homeDetailTeamHeader;
@property (weak, nonatomic) IBOutlet FSPGameDetailTeamHeader *awayDetailTeamHeader;


/**
 * Updates matchup container to contain appropriate accessibility text.
 */
- (void)updateMatchupAccessibilityLabels;

- (BOOL)updateLabelFontForStat:(UILabel *)firstStat Stat:(UILabel *)secondStat largerHighlighted:(BOOL)larger;

@end

@implementation FSPNFLMatchupView {
    CGFloat fontSize;
}

@synthesize homeTeamWinLossLabel;
@synthesize awayTeamWinLossLabel;
@synthesize homeTeamYPGLabel;
@synthesize awayTeamYPGLabel;
@synthesize homeTeamOYPGLabel;
@synthesize awayTeamOYPGLabel;
@synthesize homeTeamTOGLabel;
@synthesize awayTeamTOGLabel;


- (id)init
{
    UINib *matchupNib = [UINib nibWithNibName:@"FSPNFLMatchupView" bundle:nil];
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
    
    //If either team does not have an overall record, mark information as incomplete and do not update subviews.
    if(!homeTeam.yardsPerGame || !awayTeam.yardsPerGame) {
        self.informationComplete = NO;
        return;
    } else {
        self.informationComplete = YES;
    }
    
    self.homeTeamWinLossLabel.text = [NSString stringWithFormat:@"%@", game.homeTeam.overallRecord.winLossRecordString];
	if (game.viewType == FSPNFLViewType) self.homeTeamWinLossLabel.text = [self.homeTeamWinLossLabel.text stringByAppendingFormat:@" (%@)", game.homeTeam.winsRankingString];
    self.awayTeamWinLossLabel.text = [NSString stringWithFormat:@"%@", game.awayTeam.overallRecord.winLossRecordString];
	if (game.viewType == FSPNFLViewType) self.awayTeamWinLossLabel.text = [self.awayTeamWinLossLabel.text stringByAppendingFormat:@" (%@)", game.awayTeam.winsRankingString];
    
    if (homeTeam.winPercent && awayTeam.winPercent) {
        if (homeTeam.winPercent.floatValue > awayTeam.winPercent.floatValue) {
            self.homeTeamWinLossLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
            self.homeTeamWinLossLabel.textColor = [UIColor whiteColor];
            self.awayTeamWinLossLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];
            self.awayTeamWinLossLabel.textColor = [UIColor fsp_lightBlueColor];
        } else if (homeTeam.winPercent.floatValue < awayTeam.winPercent.floatValue) {
            self.awayTeamWinLossLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:fontSize];
            self.awayTeamWinLossLabel.textColor = [UIColor whiteColor];
            self.homeTeamWinLossLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:fontSize];
            self.homeTeamWinLossLabel.textColor = [UIColor fsp_lightBlueColor];
        }
    }
    
    self.homeTeamYPGLabel.text = [NSString stringWithFormat:@"%@", game.homeTeam.yardsPerGame];
	if (game.viewType == FSPNFLViewType) self.homeTeamYPGLabel.text = [self.homeTeamYPGLabel.text stringByAppendingFormat:@" (%@)", game.homeTeam.yardsPerGameRankingString];
    self.awayTeamYPGLabel.text = [NSString stringWithFormat:@"%@", game.awayTeam.yardsPerGame];
	if (game.viewType == FSPNFLViewType) self.awayTeamYPGLabel.text = [self.awayTeamYPGLabel.text stringByAppendingFormat:@" (%@)", game.awayTeam.yardsPerGameRankingString];
    [self updateLabelFontForStat:self.homeTeamYPGLabel Stat:self.awayTeamYPGLabel largerHighlighted:YES];
    
    self.homeTeamOYPGLabel.text = [NSString stringWithFormat:@"%@", game.homeTeam.opponentYardsPerGame];
	if (game.viewType == FSPNFLViewType) self.homeTeamOYPGLabel.text = [self.homeTeamOYPGLabel.text stringByAppendingFormat:@" (%@)", game.homeTeam.opponentYardsPerGameRankingString];
    self.awayTeamOYPGLabel.text = [NSString stringWithFormat:@"%@", game.awayTeam.opponentYardsPerGame];
	if (game.viewType == FSPNFLViewType) self.awayTeamOYPGLabel.text = [self.awayTeamOYPGLabel.text stringByAppendingFormat:@" (%@)", game.awayTeam.opponentYardsPerGameRankingString];
    [self updateLabelFontForStat:self.awayTeamOYPGLabel Stat:self.homeTeamOYPGLabel largerHighlighted:NO];
    
    self.homeTeamTOGLabel.text = [NSString stringWithFormat:@"%@", game.homeTeam.turnoversPerGame];
	if (game.viewType == FSPNFLViewType) self.homeTeamTOGLabel.text = [self.homeTeamTOGLabel.text stringByAppendingFormat:@" (%@)", game.homeTeam.turnoversPerGameRankingString];
    self.awayTeamTOGLabel.text = [NSString stringWithFormat:@"%@", game.awayTeam.turnoversPerGame];
	if (game.viewType == FSPNFLViewType) self.awayTeamTOGLabel.text = [self.awayTeamTOGLabel.text stringByAppendingFormat:@" (%@)", game.awayTeam.turnoversPerGameRankingString];
    [self updateLabelFontForStat:self.awayTeamTOGLabel Stat:self.homeTeamTOGLabel largerHighlighted:NO];
    
    [self updateMatchupAccessibilityLabels];
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

- (void)updateMatchupAccessibilityLabels;
{    
    // Matchup accessibility identifiers -- used for automated QA testing
    // TODO: move this to someplace where we only need to set it once
    self.accessibilityIdentifier = @"pregameMatchup";    
    self.homeTeamWinLossLabel.accessibilityIdentifier = @"homeRecord";
    self.awayTeamWinLossLabel.accessibilityIdentifier = @"awayRecord";
    self.homeTeamYPGLabel.accessibilityIdentifier = @"homeYPG";
    self.awayTeamYPGLabel.accessibilityIdentifier = @"awayYPG";
    self.homeTeamOYPGLabel.accessibilityIdentifier = @"homeOYPG";
    self.awayTeamOYPGLabel.accessibilityIdentifier = @"awayOYPG";
    self.homeTeamTOGLabel.accessibilityIdentifier = @"homeTOG";
    self.awayTeamTOGLabel.accessibilityIdentifier = @"awayTOG";
    
    // Dynamic accessibility data for each matchup entry -- could be grouped into containers
    self.homeTeamWinLossLabel.accessibilityLabel = self.homeTeamWinLossLabel.text;
    self.awayTeamWinLossLabel.accessibilityLabel = self.awayTeamWinLossLabel.text;
    self.homeTeamYPGLabel.accessibilityLabel = self.homeTeamYPGLabel.text;
    self.awayTeamYPGLabel.accessibilityLabel = self.awayTeamYPGLabel.text;
    self.homeTeamOYPGLabel.accessibilityLabel = self.homeTeamOYPGLabel.text;
    self.awayTeamOYPGLabel.accessibilityLabel = self.awayTeamOYPGLabel.text;
    self.homeTeamTOGLabel.accessibilityLabel = self.homeTeamTOGLabel.text;
    self.awayTeamTOGLabel.accessibilityLabel = self.awayTeamTOGLabel.text;
}

@end
