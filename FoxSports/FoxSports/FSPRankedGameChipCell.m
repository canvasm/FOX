//
//  FSPRankedGameChipCell.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPRankedGameChipCell.h"
#import "FSPGame.h"
#import "FSPTeam.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@interface FSPRankedGameChipCell()

@property (weak, nonatomic) IBOutlet UILabel *awayTeamRankLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamRankLabel;

@end

@implementation FSPRankedGameChipCell
@synthesize awayTeamRankLabel;
@synthesize homeTeamRankLabel;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIFont *rankFont = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:16.0f];
    self.homeTeamRankLabel.font = rankFont;
    self.awayTeamRankLabel.font = rankFont;
    
    UIColor *rankColor = [UIColor fsp_colorWithIntegralRed:46 green:83 blue:122 alpha:1];
    self.homeTeamRankLabel.textColor = rankColor;
    self.awayTeamRankLabel.textColor = rankColor;
}

- (void)populateCellWithEvent:(FSPGame *)game
{
    [super populateCellWithEvent:game];
    
    NSNumber *homeTeamRank = game.homeTeam.primaryRank;
    self.homeTeamRankLabel.text = [homeTeamRank intValue] > 0 ? [homeTeamRank stringValue] : @"";
    NSNumber *awayTeamRank = game.awayTeam.primaryRank;
    self.awayTeamRankLabel.text = [awayTeamRank intValue] > 0 ? [game.awayTeam.primaryRank stringValue] : @"";
}

@end
