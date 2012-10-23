//
//  FSPHockeyGame.h
//  FoxSports
//
//  Created by Ryan McPherson on 8/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPGame.h"

@class FSPHockeyPeriodStats;

@interface FSPHockeyGame : FSPGame

@property (nonatomic, retain) NSNumber * homePenaltyMinutes;
@property (nonatomic, retain) NSNumber * awayPenaltyMinutes;
@property (nonatomic, retain) NSNumber * homePowerPlayOpportunities;
@property (nonatomic, retain) NSNumber * awayPowerPlayOpportunities;
@property (nonatomic, retain) NSNumber * homePowerPlayGoals;
@property (nonatomic, retain) NSNumber * awayPowerPlayGoals;
@property (nonatomic, retain) NSNumber * homeHits;
@property (nonatomic, retain) NSNumber * awayHits;
@property (nonatomic, retain) NSNumber * homeFaceOffWins;
@property (nonatomic, retain) NSNumber * awayFaceOffWins;
@property (nonatomic, retain) NSNumber * homeTurnovers;
@property (nonatomic, retain) NSNumber * awayTurnovers;
@property (nonatomic, retain) NSNumber * homeSteals;
@property (nonatomic, retain) NSNumber * awaySteals;
@property (nonatomic, retain) NSNumber * homeBlockedShots;
@property (nonatomic, retain) NSNumber * awayBlockedShots;
@property (nonatomic, retain) NSNumber * homeShotsOnGoal;
@property (nonatomic, retain) NSNumber * awayShotsOnGoal;

@property (nonatomic, retain) NSSet * homePeriodStats;
@property (nonatomic, retain) NSSet * awayPeriodStats;

@end


@interface FSPHockeyGame (CoreDataGeneratedAccessors)

- (void)addHomePeriodStatsObject:(FSPHockeyPeriodStats *)stats;
- (void)removeHomePeriodStatsObject:(FSPHockeyPeriodStats *)stats;
- (void)addHomePeriodStats:(NSSet *)stats;
- (void)removeHomePeriodStats:(NSSet *)stats;

- (void)addAwayPeriodStatsObject:(FSPHockeyPeriodStats *)stats;
- (void)removeAwayPeriodStatsObject:(FSPHockeyPeriodStats *)stats;
- (void)addAwayPeriodStats:(NSSet *)stats;
- (void)removeAwayPeriodStats:(NSSet *)stats;

@end