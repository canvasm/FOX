//
//  FSPNBAStandingsCell.m
//  FoxSports
//
//  Created by Laura Savino on 2/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNBAStandingsCell.h"
#import "FSPTeam.h"
#import "FSPTeamRecord.h"


@interface FSPNBAStandingsCell () {}

@property (nonatomic, weak) IBOutlet UILabel *gamesBackLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastTenLabel;

@end

@implementation FSPNBAStandingsCell

@synthesize gamesBackLabel = _gamesBackLabel;
@synthesize lastTenLabel = _lastTenLabel;


- (void)populateWithTeam:(FSPTeam *)team;
{
    [super populateWithTeam:team];
    self.gamesBackLabel.text = team.conferenceGamesBack;
    self.lastTenLabel.text = team.lastTenGamesRecord.winLossRecordString;
    
    // Don't indent team name labels for NCAA
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (team.viewType == FSPNCAABViewType || team.viewType == FSPNCAAWBViewType) {
            CGRect teamNameLabelRect = self.teamNameLabel.frame;
            teamNameLabelRect.origin.x = 20;
            self.teamNameLabel.frame = teamNameLabelRect;
        }
    }
}

- (NSString *)accessibilityLabel
{
    return [NSString stringWithFormat:@"%@, %@ wins, %@ losses, %@ winning percentage, %@ games behind, %@ at home, %@ away, %@ conference record, %@ division record, current streak %@", self.teamNameLabel.accessibilityLabel, self.winsLabel.accessibilityLabel, self.lossesLabel.accessibilityLabel, self.percentLabel.accessibilityLabel, self.gamesBackLabel.accessibilityLabel, self.homeRecordLabel.accessibilityLabel, self.awayRecordLabel.accessibilityLabel, self.conferenceRecordLabel.accessibilityLabel, self.divisionRecordLabel.accessibilityLabel, self.streakLabel.accessibilityLabel];
}

@end
