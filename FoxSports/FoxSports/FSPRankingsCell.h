//
//  FSPRankingsCell.h
//  FoxSports
//
//  Created by Joshua Dubey on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsCell.h"

@class FSPTeamRanking;

@interface FSPRankingsCell : FSPStandingsCell

- (void)populateWithTeam:(FSPTeamRanking *)ranking;

@end
