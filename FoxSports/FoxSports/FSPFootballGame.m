//
//  FSPFootballGame.m
//  FoxSports
//
//  Created by Chase Latta on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPFootballGame.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPTeam.h"

@implementation FSPFootballGame

@dynamic homeTeamPossession;
@dynamic fieldPosition;

@dynamic awayFirstDowns;
@dynamic awayFourthDownEfficiency;
@dynamic awayFumblesLost;
@dynamic awayInterceptionsThrown;
@dynamic awayThirdDownEfficiency;
@dynamic awayTimeOfPossession;
@dynamic awayTotalPassAttempts;
@dynamic awayTotalPassCompletions;
@dynamic awayTotalPassingYards;
@dynamic awayTotalRushes;
@dynamic awayTotalRushingYards;
@dynamic awayTotalYards;
@dynamic awayYardsPerPass;
@dynamic awayYardsPerRush;

@dynamic homeFirstDowns;
@dynamic homeFourthDownEfficiency;
@dynamic homeFumblesLost;
@dynamic homeInterceptionsThrown;
@dynamic homeThirdDownEfficiency;
@dynamic homeTimeOfPossession;
@dynamic homeTotalPassAttempts;
@dynamic homeTotalPassCompletions;
@dynamic homeTotalPassingYards;
@dynamic homeTotalRushes;
@dynamic homeTotalRushingYards;
@dynamic homeTotalYards;
@dynamic homeYardsPerPass;
@dynamic homeYardsPerRush;

- (NSUInteger)maxTimeouts
{
    return 3;
}

- (void)populateWithLeagueGameBundleDictionary:(NSDictionary *)eventData
{
    [super populateWithLeagueGameBundleDictionary:eventData];
    [self updateFootballChipDataWithDictionary:eventData];
}

- (void)populateSegmentInformationWithDictionary:(NSDictionary *)segmentData
{
    [super populateSegmentInformationWithDictionary:segmentData];
    [self updateFootballChipDataWithDictionary:segmentData];
}

- (void)updateFootballChipDataWithDictionary:(NSDictionary *)eventData
{
    NSNumber *yardsToGo = [eventData fsp_objectForKey:@"YFG" defaultValue:@0];
    self.fieldPosition = @(100 - yardsToGo.intValue);
    if ([[eventData fsp_objectForKey:@"PID" defaultValue:@(-1)] isEqualToNumber:self.homeTeamLiveEngineID])
        self.homeTeamPossession = @(YES);
    else 
        self.homeTeamPossession = @(NO);
}

- (void)populateWithLiveTeamStatsDictionary:(NSDictionary *)eventData
{
    [super populateWithLiveTeamStatsDictionary:eventData];
    NSNumber * teamID = [eventData objectForKey:@"ID"];
    NSNumber * noValue = @0;
    if ([teamID isEqualToNumber:self.homeTeamLiveEngineID]) {
        self.homeFirstDowns = [eventData fsp_objectForKey:@"FD" defaultValue:noValue];
        self.homeFourthDownEfficiency = [eventData fsp_objectForKey:@"E4" defaultValue:noValue];
        self.homeFumblesLost = [eventData fsp_objectForKey:@"FBL" defaultValue:noValue];
        self.homeInterceptionsThrown = [eventData fsp_objectForKey:@"INT" defaultValue:noValue];
        self.homeThirdDownEfficiency = [eventData fsp_objectForKey:@"E3" defaultValue:noValue];

		NSDictionary *timeOfPossession = [eventData fsp_objectForKey:@"TOP" expectedClass:[NSDictionary class]];
        self.homeTimeOfPossession = [NSString stringWithFormat:@"%@:%@", [timeOfPossession valueForKey:@"M"], [timeOfPossession valueForKey:@"S"]];

        self.homeTotalPassAttempts = [eventData fsp_objectForKey:@"PAA" defaultValue:noValue];
        self.homeTotalPassCompletions = [eventData fsp_objectForKey:@"PAC" defaultValue:noValue];
        self.homeTotalPassingYards = [eventData fsp_objectForKey:@"NYPA" defaultValue:noValue];
        self.homeTotalRushes = [eventData fsp_objectForKey:@"RU" defaultValue:noValue];
        self.homeTotalRushingYards = [eventData fsp_objectForKey:@"NYRU" defaultValue:noValue];
        self.homeTotalYards = [eventData fsp_objectForKey:@"TNY" defaultValue:noValue];
        self.homeYardsPerPass = [eventData fsp_objectForKey:@"PAAV" defaultValue:@"--"];
        self.homeYardsPerRush = [eventData fsp_objectForKey:@"RUAV" defaultValue:@"--"];
    } else if ([teamID isEqualToNumber:self.awayTeamLiveEngineID]) {
        self.awayFirstDowns = [eventData fsp_objectForKey:@"FD" defaultValue:noValue];
        self.awayFourthDownEfficiency = [eventData fsp_objectForKey:@"E4" defaultValue:noValue];
        self.awayFumblesLost = [eventData fsp_objectForKey:@"FBL" defaultValue:noValue];
        self.awayInterceptionsThrown = [eventData fsp_objectForKey:@"INT" defaultValue:noValue];
        self.awayThirdDownEfficiency = [eventData fsp_objectForKey:@"E3" defaultValue:noValue];

		NSDictionary *timeOfPossession = [eventData fsp_objectForKey:@"TOP" expectedClass:[NSDictionary class]];
        self.awayTimeOfPossession = [NSString stringWithFormat:@"%@:%@", [timeOfPossession valueForKey:@"M"], [timeOfPossession valueForKey:@"S"]];

        self.awayTotalPassAttempts = [eventData fsp_objectForKey:@"PAA" defaultValue:noValue];
        self.awayTotalPassCompletions = [eventData fsp_objectForKey:@"PAC" defaultValue:noValue];
		self.awayTotalPassingYards = [eventData fsp_objectForKey:@"NYPA" defaultValue:noValue];
        self.awayTotalRushes = [eventData fsp_objectForKey:@"RU" defaultValue:noValue];
        self.awayTotalRushingYards = [eventData fsp_objectForKey:@"NYRU" defaultValue:noValue];
        self.awayTotalYards = [eventData fsp_objectForKey:@"TNY" defaultValue:noValue];
        self.awayYardsPerPass = [eventData fsp_objectForKey:@"PAAV" defaultValue:@"--"];
        self.awayYardsPerRush = [eventData fsp_objectForKey:@"RUAV" defaultValue:@"--"];
    }
}

- (BOOL)matchupAvailable;
{
    if (self.homeTeam.yardsPerGame || self.awayTeam.yardsPerGame) {
        return YES;
    }
    return NO;
}

- (BOOL)isOvertime;
{
    if (self.segmentNumber.intValue > 4) return YES;
    else return NO;
}

@end
