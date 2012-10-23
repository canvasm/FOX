//
//  FSPMLBStandingsCell.m
//  FoxSports
//
//  Created by Laura Savino on 4/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMLBStandingsCell.h"
#import "FSPTeamRecord.h"
#import "FSPTeam.h"

@interface FSPMLBStandingsCell ()

@property (nonatomic, weak) IBOutlet UILabel *gamesBackLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastTenRecordLabel;

@end

@implementation FSPMLBStandingsCell
@synthesize gamesBackLabel = _gamesBackLabel;
@synthesize lastTenRecordLabel = _lastTenRecordLabel;

- (void)populateWithTeam:(FSPTeam *)team
{
    [super populateWithTeam:team];
    self.gamesBackLabel.text = team.divisionGamesBack;
    FSPTeamRecord *lastTenRecord = team.lastTenGamesRecord;
    self.lastTenRecordLabel.text = lastTenRecord.winLossRecordString;
}

- (void)populateWithWildcardTeam:(FSPTeam *)team;
{
    [super populateWithTeam:team];
    self.gamesBackLabel.text = team.wildCardGamesBack;
    FSPTeamRecord *lastTenRecord = team.lastTenGamesRecord;
    self.lastTenRecordLabel.text = lastTenRecord.winLossRecordString;
}

- (NSString *)accessibilityLabel
{
    return [NSString stringWithFormat:@"%@, %@ wins, %@ losses, %@ winning percentage, %@ games behind, %@ at home, %@ away, %@ conference record, %@ division record, current streak %@", self.teamNameLabel.accessibilityLabel, self.winsLabel.accessibilityLabel, self.lossesLabel.accessibilityLabel, self.percentLabel.accessibilityLabel, self.gamesBackLabel.accessibilityLabel, self.homeRecordLabel.accessibilityLabel, self.awayRecordLabel.accessibilityLabel, self.conferenceRecordLabel.accessibilityLabel, self.divisionRecordLabel.accessibilityLabel, self.streakLabel.accessibilityLabel];
}

@end
