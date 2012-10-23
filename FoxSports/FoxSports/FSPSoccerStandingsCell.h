//
//  FSPSoccerStandingsCell.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/17/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsCell.h"

@class FSPOrganization;

@interface FSPSoccerStandingsCell : FSPStandingsCell

/*!
 @abstract Populates a cell with soccer team standings data.
 @param team The team to display in the cell.
 @param organization The soccer league in which the team is ranked.
 @param rank The team's ranking in the standings.
 */
- (void)populateWithTeam:(FSPTeam *)team organization:(FSPOrganization *)organization rank:(NSInteger)rank;

@end
