//
//  FSPBasketballPlayer.h
//  FoxSports
//
//  Created by Jason Whitford on 3/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPTeamPlayer.h"


@interface FSPBasketballPlayer : FSPTeamPlayer

@property (nonatomic, retain) NSNumber * assists;
@property (nonatomic, retain) NSNumber * blocks;
@property (nonatomic, retain) NSNumber * defensiveRebounds;
@property (nonatomic, retain) NSNumber * disqualifications;
@property (nonatomic, retain) NSNumber * ejections;
@property (nonatomic, retain) NSNumber * fieldGoalPercentage;
@property (nonatomic, retain) NSNumber * fieldGoalsAttempted;
@property (nonatomic, retain) NSNumber * fieldGoalsMade;
@property (nonatomic, retain) NSNumber * flagrantFouls;
@property (nonatomic, retain) NSNumber * freeThrowPercentage;
@property (nonatomic, retain) NSNumber * freeThrowsAttempted;
@property (nonatomic, retain) NSNumber * freeThrowsMade;
@property (nonatomic, retain) NSNumber * games;
@property (nonatomic, retain) NSNumber * gamesStarted;
@property (nonatomic, retain) NSNumber * minutesPlayed;
@property (nonatomic, retain) NSNumber * offensiveRebounds;
@property (nonatomic, retain) NSNumber * personalFouls;
@property (nonatomic, retain) NSNumber * plusMinus;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSNumber * rebounds;
@property (nonatomic, retain) NSNumber * secondsPlayed;
@property (nonatomic, retain) NSNumber * steals;
@property (nonatomic, retain) NSNumber * technicalFouls;
@property (nonatomic, retain) NSNumber * threePointPercentage;
@property (nonatomic, retain) NSNumber * threePointsAttempted;
@property (nonatomic, retain) NSNumber * threePointsMade;
@property (nonatomic, retain) NSNumber * turnovers;

@end
