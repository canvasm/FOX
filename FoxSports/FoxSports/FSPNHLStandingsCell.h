//
//  FSPNHLStandingsCell.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 8/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsCell.h"
#import "FSPStandingsTableViewController.h"

@class FSPTeam;

@interface FSPNHLStandingsCell : FSPStandingsCell

@property (nonatomic, strong) FSPTeam *team;

/*!
 @abstract Populates an instance with a team and standings type
 @param team The team to populate the cell with.
 @param standingsType The type of standings the cell should display for.
 @discussion The standingsType is used to display the conference rank label if the cell is displayed in conference standings.
 */
- (void)populateWithTeam:(FSPTeam *)team conferenceType:(FSPStandingsSegmentSelected)standingsType;

@end
