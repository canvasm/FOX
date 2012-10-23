//
//  FSPHockeyGame.m
//  FoxSports
//
//  Created by Ryan McPherson on 8/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPHockeyGame.h"
#import "FSPHockeyPeriodStats.h"
#import "FSPCoreDataManager.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPHockeyGame

@dynamic homePenaltyMinutes;
@dynamic awayPenaltyMinutes;
@dynamic homePowerPlayOpportunities;
@dynamic awayPowerPlayOpportunities;
@dynamic homePowerPlayGoals;
@dynamic awayPowerPlayGoals;
@dynamic homeHits;
@dynamic awayHits;
@dynamic homeFaceOffWins;
@dynamic awayFaceOffWins;
@dynamic homeTurnovers;
@dynamic awayTurnovers;
@dynamic homeSteals;
@dynamic awaySteals;
@dynamic homeBlockedShots;
@dynamic awayBlockedShots;
@dynamic homeShotsOnGoal;
@dynamic awayShotsOnGoal;

@dynamic homePeriodStats;
@dynamic awayPeriodStats;

- (NSUInteger)maxTimeouts
{
    return 1;
}

- (void)populateWithLiveTeamStatsDictionary:(NSDictionary *)eventData
{
    [super populateWithLiveTeamStatsDictionary:eventData];
    
    NSNumber * teamID = [eventData objectForKey:@"ID"];
    NSNumber * noValue = @0;
    
    if ([teamID isEqualToNumber:self.homeTeamLiveEngineID]) {
        self.homePenaltyMinutes = [eventData fsp_objectForKey:@"PIM" defaultValue:noValue];
        self.homePowerPlayOpportunities = [eventData fsp_objectForKey:@"PPO" defaultValue:noValue];
        self.homePowerPlayGoals = [eventData fsp_objectForKey:@"PPG" defaultValue:noValue];
        self.homeHits = [eventData fsp_objectForKey:@"H" defaultValue:noValue];
        self.homeFaceOffWins = [eventData fsp_objectForKey:@"FOW" defaultValue:noValue];
        self.homeTurnovers = [eventData fsp_objectForKey:@"TO" defaultValue:noValue];
        self.homeSteals = [eventData fsp_objectForKey:@"STL" defaultValue:noValue];
        self.homeBlockedShots = [eventData fsp_objectForKey:@"BL" defaultValue:noValue];
        self.homeShotsOnGoal = [eventData fsp_objectForKey:@"GSOG" defaultValue:noValue];
        self.homePeriodStats = nil;
        NSSet *homePerStats = [self createFSPHockeyPeriodStatsonMasterContextFromArray:[eventData fsp_objectForKey:@"PSOG" defaultValue:NSArray.new] isHome:YES];
        [self addHomePeriodStats:homePerStats];
        
    } else if ([teamID isEqualToNumber:self.awayTeamLiveEngineID]) {
        self.awayPenaltyMinutes = [eventData fsp_objectForKey:@"PIM" defaultValue:noValue];
        self.awayPowerPlayOpportunities = [eventData fsp_objectForKey:@"PPO" defaultValue:noValue];
        self.awayPowerPlayGoals = [eventData fsp_objectForKey:@"PPG" defaultValue:noValue];
        self.awayHits = [eventData fsp_objectForKey:@"H" defaultValue:noValue];
        self.awayFaceOffWins = [eventData fsp_objectForKey:@"FOW" defaultValue:noValue];
        self.awayTurnovers = [eventData fsp_objectForKey:@"TO" defaultValue:noValue];
        self.awaySteals = [eventData fsp_objectForKey:@"STL" defaultValue:noValue];
        self.awayBlockedShots = [eventData fsp_objectForKey:@"BL" defaultValue:noValue];
        self.awayShotsOnGoal = [eventData fsp_objectForKey:@"GSOG" defaultValue:noValue];
        self.awayPeriodStats = nil;
        NSSet *awayPerStats = [self createFSPHockeyPeriodStatsonMasterContextFromArray:[eventData fsp_objectForKey:@"PSOG" defaultValue:NSArray.new] isHome:NO];
        [self addAwayPeriodStats:awayPerStats];
    }
}

- (NSSet *)createFSPHockeyPeriodStatsonMasterContextFromArray:(NSArray *)stats isHome:(BOOL)isHome
{
    NSMutableSet *databaseStats = [NSMutableSet set];
    NSManagedObjectContext *context = self.managedObjectContext;
    
    for (NSDictionary *stat in stats) {
        FSPHockeyPeriodStats *periodStats = [NSEntityDescription insertNewObjectForEntityForName:@"FSPHockeyPeriodStats" inManagedObjectContext:context];
        periodStats.period = [stat fsp_objectForKey:@"P" defaultValue:@-1];
        periodStats.shotsOnGoal = [stat fsp_objectForKey:@"SOG" defaultValue:@-1];
        if (isHome) periodStats.homeGame = self;
        else periodStats.awayGame = self;
        [databaseStats addObject:periodStats];
    }
    
    return [NSMutableSet setWithSet:databaseStats];
}

- (BOOL)matchupAvailable
{
    return YES;
}

- (BOOL)isOvertime
{
    if (self.segmentNumber.intValue > 3) return YES;
    else return NO;
}

@end
