//
//  FSPTeamScheduleCell.h
//  FoxSports
//
//  Created by greay on 6/18/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleCell.h"

@class FSPTeam;
@interface FSPTeamScheduleCell : FSPScheduleCell

@property (nonatomic, strong) FSPTeam *team;

- (NSString *)lastNameFromFullName:(NSString *)fullName;

@end
