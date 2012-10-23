//
//  FSPScheduleNFLGame.h
//  FoxSports
//
//  Created by Joshua Dubey on 6/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleGame.h"

@interface FSPScheduleNFLGame : FSPScheduleGame

@property (nonatomic, strong) NSString *topGamePasserStats;
@property (nonatomic, strong) NSString *topGameRusherStats;
@property (nonatomic, strong) NSString *topGameReceiverStats;

@property (nonatomic, strong) NSString *homeTeamPasserStats;
@property (nonatomic, strong) NSString *homeTeamRusherStats;
@property (nonatomic, strong) NSString *homeTeamReceiverStats;

@property (nonatomic, strong) NSString *awayTeamPasserStats;
@property (nonatomic, strong) NSString *awayTeamRusherStats;
@property (nonatomic, strong) NSString *awayTeamReceiverStats;

@property (nonatomic, assign) NSUInteger weekNumber;
@property (nonatomic, assign) BOOL showDateLabel;

@end
