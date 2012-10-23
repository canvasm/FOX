//
//  FSPTeamRanking.m
//  FoxSports
//
//  Created by Joshua Dubey on 9/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTeamRanking.h"
#import "FSPTeam.h"
#import "NSDictionary+FSPExtensions.h"


NSString * const FSPTeamRankingPollNameKey = @"pollName";
NSString * const FSPTeamRankingPollTypeKey = @"pollType";
NSString * const FSPTeamRankingRankKey = @"rank";
NSString * const FSPTeamRankingPreviousRankKey = @"previousRank";
NSString * const FSPTeamRankingDroppedKey = @"dropped";
NSString * const FSPTeamRankingPointsKey = @"points";
NSString * const FSPTeamRankingRankedTeamsKey = @"rankedTeams";
NSString * const FSPTeamRankingRankingDictionaryKey = @"rankingDictionary";

NSString * const FSPTeamRankingAPPollTypeKey = @"AP";
NSString * const FSPTeamRankingUsaTodayPollTypeKey = @"USA";
NSString * const FSPTeamRankingPowerTypeKey = @"POWER";

@implementation FSPTeamRanking

@dynamic pollName;
@dynamic pollType;
@dynamic rank;
@dynamic isRanked;
@dynamic previousRank;
@dynamic dropped;
@dynamic points;
@dynamic team;

- (void)populateWithDictionary:(NSDictionary *)rankingDictionary
{
    self.pollName = [rankingDictionary fsp_objectForKey:FSPTeamRankingPollNameKey defaultValue:@""];
    self.pollType = [rankingDictionary fsp_objectForKey:FSPTeamRankingPollTypeKey defaultValue:@""];
    self.rank = [rankingDictionary fsp_objectForKey:FSPTeamRankingRankKey defaultValue:@0];
    self.previousRank = [rankingDictionary fsp_objectForKey:FSPTeamRankingPreviousRankKey defaultValue:@0];
    self.dropped = [rankingDictionary fsp_objectForKey:FSPTeamRankingDroppedKey defaultValue:@0];
    self.points = [rankingDictionary fsp_objectForKey:FSPTeamRankingPointsKey defaultValue:@0];
}

@end
