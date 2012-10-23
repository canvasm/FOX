//
//  FSPMLBTeamScheduleCell.h
//  FoxSports
//
//  Created by Joshua Dubey on 6/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTeamScheduleCell.h"
#import "FSPScheduleMLBGame.h"
#import "NSDate+FSPExtensions.h"
#import "FSPTeam.h"
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"


@interface FSPMLBTeamScheduleCell : FSPTeamScheduleCell

@property (nonatomic, weak, readonly) UILabel *col4Label;
@property (nonatomic, weak, readonly) UILabel *col5Label;
@property (nonatomic, weak, readonly) UILabel *dateChannelSublabel;

@end
