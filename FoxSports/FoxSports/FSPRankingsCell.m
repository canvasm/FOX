//
//  FSPRankingsCell.m
//  FoxSports
//
//  Created by Joshua Dubey on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPRankingsCell.h"
#import "FSPTeam.h"
#import "FSPTeamRanking.h"
#import "FSPTeamRecord.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

@interface FSPRankingsCell ()

@property (weak, nonatomic) IBOutlet UILabel *rankingsLabel;

@end

@implementation FSPRankingsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.rankingsLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:14];
    self.rankingsLabel.backgroundColor = [UIColor clearColor];
    self.rankingsLabel.textColor = [UIColor fsp_colorWithIntegralRed:115 green:115 blue:115 alpha:1.0];
    self.rankingsLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.rankingsLabel.shadowOffset = CGSizeMake(0, -1);
    
}

- (void)populateWithTeam:(FSPTeamRanking *)ranking
{
    self.teamNameLabel.text = ranking.team.shortNameDisplayString;
    self.rankingsLabel.text = [ranking.rank description];
    self.conferenceRecordLabel.text = ranking.team.conferenceRecord.winLossRecordString;
}

@end
