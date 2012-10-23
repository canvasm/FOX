//
//  FSPScheduleGame.h
//  FoxSports
//
//  Created by greay on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleEvent.h"

@class FSPTeam;
@class FSPOrganization;

@interface FSPScheduleGame : FSPScheduleEvent

@property (nonatomic, strong) NSString * homeTeamName;
@property (nonatomic, strong) NSString * awayTeamName;

@property (nonatomic, strong) NSString * homeTeamAbbreviation;
@property (nonatomic, strong) NSString * awayTeamAbbreviation;

@property (nonatomic, strong) NSString * homeTeamScore;
@property (nonatomic, strong) NSString * awayTeamScore;

@property (nonatomic, strong) FSPTeam *homeTeam;
@property (nonatomic, strong) FSPTeam *awayTeam;

- (void)populateWithDictionary:(NSDictionary *)dictionary;

@end
