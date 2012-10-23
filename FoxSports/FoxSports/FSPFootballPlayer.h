//
//  FSPFootballPlayer.h
//  FoxSports
//
//  Created by Matthew Fay on 7/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPTeamPlayer.h"


@interface FSPFootballPlayer : FSPTeamPlayer

@property (nonatomic, retain) NSNumber * foxPointsDefense;
@property (nonatomic, retain) NSNumber * foxPointsKicking;
@property (nonatomic, retain) NSNumber * foxPointsPassing;
@property (nonatomic, retain) NSNumber * foxPointsReceiving;
@property (nonatomic, retain) NSNumber * foxPointsRushing;
@property (nonatomic, retain) NSNumber * foxPointsTotal;
@property (nonatomic, retain) NSNumber * defensiveForcedFumbles;
@property (nonatomic, retain) NSNumber * fumblesLost;
@property (nonatomic, retain) NSNumber * fumblesRecovered;
@property (nonatomic, retain) NSNumber * fieldGoalAttempts;
@property (nonatomic, retain) NSNumber * fieldGoalLongestLength;
@property (nonatomic, retain) NSNumber * fieldGoalsMade;
@property (nonatomic, retain) NSNumber * fieldGoalPercentage;
@property (nonatomic, retain) NSNumber * defensiveInterceptions;
@property (nonatomic, retain) NSNumber * defensiveInterceptionTouchdowns;
@property (nonatomic, retain) NSNumber * defensiveInterceptionYards;
@property (nonatomic, retain) NSNumber * kickReturns;
@property (nonatomic, retain) NSNumber * kickReturnAverage;
@property (nonatomic, retain) NSNumber * kickReturnLongest;
@property (nonatomic, retain) NSNumber * kickReturnTouchdowns;
@property (nonatomic, retain) NSNumber * kickReturnYards;
@property (nonatomic, retain) NSNumber * passingAttempts;
@property (nonatomic, retain) NSNumber * passingAverage;
@property (nonatomic, retain) NSNumber * passingCompletions;
@property (nonatomic, retain) NSNumber * passingInterceptions;
@property (nonatomic, retain) NSNumber * passingTouchdowns;
@property (nonatomic, retain) NSNumber * passingYards;
@property (nonatomic, retain) NSNumber * defendedPasses;
@property (nonatomic, retain) NSNumber * puntInside20;
@property (nonatomic, retain) NSNumber * puntAverageLength;
@property (nonatomic, retain) NSNumber * puntLongestLength;
@property (nonatomic, retain) NSNumber * puntNumber;
@property (nonatomic, retain) NSNumber * puntReturns;
@property (nonatomic, retain) NSNumber * puntReturnAverage;
@property (nonatomic, retain) NSNumber * puntReturnLongest;
@property (nonatomic, retain) NSNumber * puntReturnTouchdowns;
@property (nonatomic, retain) NSNumber * puntReturnYards;
@property (nonatomic, retain) NSNumber * receptions;
@property (nonatomic, retain) NSNumber * receptionAverage;
@property (nonatomic, retain) NSNumber * receptionLongestLength;
@property (nonatomic, retain) NSNumber * receptionTouchdowns;
@property (nonatomic, retain) NSNumber * receptionYards;
@property (nonatomic, retain) NSNumber * rusingAttempts;
@property (nonatomic, retain) NSNumber * rushingAverage;
@property (nonatomic, retain) NSNumber * rushingLongestLength;
@property (nonatomic, retain) NSNumber * rushingTouchdowns;
@property (nonatomic, retain) NSNumber * rushingYards;
@property (nonatomic, retain) NSNumber * defensiveSacks;
@property (nonatomic, retain) NSNumber * totalTouchdowns;
@property (nonatomic, retain) NSNumber * defensiveTackles;
@property (nonatomic, retain) NSNumber * kickingExtraPointAttempts;
@property (nonatomic, retain) NSNumber * kickingExtraPointsMade;
@property (nonatomic, retain) NSNumber * quarterbackRating;
@property (nonatomic, retain) NSNumber * assistedTackles;

@end
