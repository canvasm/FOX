//
//  FSPSoccerGame.m
//  FoxSports
//
//  Created by Matthew Fay on 7/9/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerGame.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPSoccerGame

@dynamic homeGoalsNum;
@dynamic homeAssists;
@dynamic homeShots;
@dynamic homeShotsOnGoal;
@dynamic homeSaves;
@dynamic homeCornerKicks;
@dynamic homeFoulsCommitted;
@dynamic homeYellowCards;
@dynamic homeRedCards;
@dynamic awayAssists;
@dynamic awayCornerKicks;
@dynamic awayFoulsCommitted;
@dynamic awayGoalsNum;
@dynamic awayRedCards;
@dynamic awaySaves;
@dynamic awayShots;
@dynamic awayShotsOnGoal;
@dynamic awayYellowCards;
@dynamic aditionalMinutes;

@dynamic homeCards;
@dynamic homeGoals;
@dynamic homeSubs;
@dynamic awayCards;
@dynamic awayGoals;
@dynamic awaySubs;

@dynamic coverageLevel;

- (void)populateWithDictionary:(NSDictionary *)eventData;
{
	[super populateWithDictionary:eventData];
	self.coverageLevel = [eventData fsp_objectForKey:@"coverageLevel" expectedClass:[NSNumber class]];
}

- (void)populateWithLeagueGameBundleDictionary:(NSDictionary *)eventData
{
    [super populateWithLeagueGameBundleDictionary:eventData];
}

- (void)populateWithLiveTeamStatsDictionary:(NSDictionary *)eventData
{
    [super populateWithLiveTeamStatsDictionary:eventData];
    
    NSNumber * teamID = [eventData objectForKey:@"ID"];
    NSNumber * noValue = @0;
    if ([teamID isEqualToNumber:self.homeTeamLiveEngineID]) {
        self.homeGoalsNum = [eventData fsp_objectForKey:@"G" defaultValue:noValue];
        self.homeAssists = [eventData fsp_objectForKey:@"A" defaultValue:noValue];
        self.homeShots = [eventData fsp_objectForKey:@"S" defaultValue:noValue];
        self.homeShotsOnGoal = [eventData fsp_objectForKey:@"SOG" defaultValue:noValue];
        self.homeSaves = [eventData fsp_objectForKey:@"SV" defaultValue:noValue];
        self.homeCornerKicks = [eventData fsp_objectForKey:@"CK" defaultValue:noValue];
        self.homeFoulsCommitted = [eventData fsp_objectForKey:@"FC" defaultValue:noValue];
        self.homeYellowCards = [eventData fsp_objectForKey:@"YC" defaultValue:noValue];
        self.homeRedCards = [eventData fsp_objectForKey:@"RC" defaultValue:noValue];
    } else if ([teamID isEqualToNumber:self.awayTeamLiveEngineID]) {
        self.awayGoalsNum = [eventData fsp_objectForKey:@"G" defaultValue:noValue];
        self.awayAssists = [eventData fsp_objectForKey:@"A" defaultValue:noValue];
        self.awayShots = [eventData fsp_objectForKey:@"S" defaultValue:noValue];
        self.awayShotsOnGoal = [eventData fsp_objectForKey:@"SOG" defaultValue:noValue];
        self.awaySaves = [eventData fsp_objectForKey:@"SV" defaultValue:noValue];
        self.awayCornerKicks = [eventData fsp_objectForKey:@"CK" defaultValue:noValue];
        self.awayFoulsCommitted = [eventData fsp_objectForKey:@"FC" defaultValue:noValue];
        self.awayYellowCards = [eventData fsp_objectForKey:@"YC" defaultValue:noValue];
        self.awayRedCards = [eventData fsp_objectForKey:@"RC" defaultValue:noValue];
    }
}

- (BOOL)matchupAvailable
{
    return YES;
}

@end
