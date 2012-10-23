//
//  FSPNASCARStandingsCell.h
//  FoxSports
//
//  Created by Ryan McPherson on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsCell.h"
#import "FSPRacingPlayer.h"

@interface FSPNASCARStandingsCell : FSPStandingsCell

- (void)populateWithStats:(FSPRacingSeasonStats *)stats;

@end
