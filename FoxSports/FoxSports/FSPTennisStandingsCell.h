//
//  FSPTennisStandingsCell.h
//  FoxSports
//
//  Created by Matthew Fay on 8/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsCell.h"

@class FSPTennisSeasonStats;

@interface FSPTennisStandingsCell : FSPStandingsCell

- (void)populateWithStats:(FSPTennisSeasonStats *)stats;

@end
