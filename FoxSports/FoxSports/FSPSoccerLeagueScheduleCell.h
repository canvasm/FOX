//
//  FSPSoccerLeagueScheduleCell.h
//  FoxSports
//
//  Created by greay on 7/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTeamScheduleCell.h"

@interface FSPSoccerLeagueScheduleCell : FSPTeamScheduleCell
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *pastHomeTeam;
@property (weak, nonatomic) IBOutlet UILabel *pastAwayTeam;
@property (weak, nonatomic) IBOutlet UILabel *venue;
@property (weak, nonatomic) IBOutlet UILabel *result;
@property (weak, nonatomic) IBOutlet UILabel *futureHomeTeam;
@property (weak, nonatomic) IBOutlet UILabel *futureAwayTeam;
@property (weak, nonatomic) IBOutlet UILabel *channel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end
