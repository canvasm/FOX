//
//  FSPTeam.m
//  FoxSports
//
//  Created by Chase Latta on 2/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTeam.h"
#import "FSPGame.h"
#import "FSPPlayer.h"
#import "FSPTeamRanking.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPTeamRecord.h"
#import "UIColor+FSPExtensions.h"
#import "FSPRecordObjectValidator.h"

NSString * const FSPTeamClinchedPlayoffs = @"x";
NSString * const FSPTeamDivisionFirst = @"y";
NSString * const FSPTeamConferenceFirst = @"z";

NSString * const FSPTeamOrganizationIdentifierKey = @"fsId";
NSString * const FSPTeamConferenceNameKey = @"conference";
NSString * const FSPTeamDivisionNameKey = @"division";

NSString * const FSPValueKey = @"value";

static NSString * const FSPStreakTypeWinning = @"winning";
static NSString * const FSPStreakTypeLosing = @"losing";

@interface FSPTeam ()

- (FSPTeamRecord *)teamRecordWithType:(NSString *)type;

/**
 * These methods update stats that are specific to sport types
 */
- (void)updateTeamStatsWithBasketballArray:(NSArray *)statsArray;
- (void)updateTeamStatsWithFootballArray:(NSArray *)statsArray;
- (void)updateTeamStatsWithBaseballArray:(NSArray *)statsArray;
- (void)updateTeamStatsWithSoccerArray:(NSArray *)statsArray;
- (void)updateTeamStatsWithHockeyArray:(NSArray *)statsArray;

@end

@implementation FSPTeam

@dynamic divisionName;
@dynamic clinched;
@dynamic sportType;
@dynamic abbreviation;
@dynamic conferenceRanking;
@dynamic divisionRanking;
@dynamic rankings;
@dynamic awayGames;
@dynamic homeGames;
@dynamic streak;
@dynamic streakType;
@dynamic conferenceName;
@dynamic winPercent;
@dynamic conferenceGamesBack;
@dynamic divisionGamesBack;
@dynamic wildCardGamesBack;
@dynamic records;
@dynamic playByPlays;
@dynamic colorInHex;
@dynamic alternateColorInHex;
@dynamic teamColorNameTag;
@dynamic nickname;
@dynamic organizations;
@dynamic isEventOnly;
@dynamic pointsPerGame;
@dynamic reboundsPerGame;
@dynamic turnoversPerGame;

@dynamic opponentYardsPerGame;
@dynamic pointsAgainst;
@dynamic pointsFor;
@dynamic yardsPerGame;


@dynamic shots;
@dynamic shotsOnGoal;
@dynamic yellowCards;
@dynamic redCards;
@dynamic fouls;
@dynamic goals;
@dynamic goalsAgainst;
@dynamic gamesPlayed;
@dynamic soccerCards;
@dynamic soccerGoals;
@dynamic soccerSubs;
@dynamic goalDifferential;

@dynamic points;
@dynamic winTotal;
@dynamic goalsPerGame;
@dynamic goalsAllowedPerGame;
@dynamic powerPlayPercentage;
@dynamic penaltyKillPercentage;
@dynamic shotsPerGame;
@dynamic shotsAgainstPerGame;
@dynamic powerRanking;
@dynamic apRanking;
@dynamic usaTodayRanking;
@dynamic primaryRank;

@dynamic winsRankingString;
@dynamic yardsPerGameRankingString;
@dynamic turnoversPerGameRankingString;
@dynamic opponentYardsPerGameRankingString;

- (NSString *)gamesPlayed
{
    NSInteger gamesWon = [self.overallRecord.wins intValue];
    NSInteger gamesLost = [self.overallRecord.losses intValue];
    NSInteger gamesTied = [self.overallRecord.ties intValue];
    NSNumber *gamesPlayed = [NSNumber numberWithInt:gamesWon + gamesLost + gamesTied];
    return [gamesPlayed stringValue];
}

- (void)populateWithDictionary:(NSDictionary *)organizationData
{
    [super populateWithDictionary:organizationData];
    if(!organizationData) return;
    
    self.abbreviation = [[organizationData fsp_objectForKey:@"abbreviation" defaultValue:@""] uppercaseString];
    self.nickname = [organizationData fsp_objectForKey:@"nickname" defaultValue:@""];
    self.conferenceRanking = [organizationData fsp_objectForKey:@"ranking" defaultValue:@0];
    self.sportType = [organizationData fsp_objectForKey:@"sportType" defaultValue:@"sport"];
    self.colorInHex = [organizationData fsp_objectForKey:@"teamColor1" defaultValue:@"3284e1"];
    self.alternateColorInHex = [organizationData fsp_objectForKey:@"teamColor2" defaultValue:@"Default"];
    self.teamColorNameTag = [organizationData fsp_objectForKey:@"teamColor1Tag" defaultValue:@"242424"];
    self.isEventOnly = [organizationData fsp_objectForKey:@"isEventOnly" defaultValue:@(NO)];

#ifdef DEBUG_xmas_chips
    NSLog(@"populate team ID: %@, branch: %@ orgs: %@ with name: %@ nickname: %@", self.uniqueIdentifier, self.branch, [[[self.organizations allObjects] valueForKey:@"name"] componentsJoinedByString:@","], self.name, self.nickname);
#endif
    
    NSString *conference = [organizationData objectForKey:@"conferenceName"];
    if (conference) 
        self.conferenceName = conference;
}

+ (NSString *)teamEntityNameForSportType:(NSString *)sportType;
{
    if(sportType == nil)
        return @"FSPTeam";
    static NSDictionary *lookupDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        lookupDictionary = @{@"sport": @"FSPTeam"};
    });
   
   NSString *teamEntityName = [lookupDictionary objectForKey:sportType];
   if(!teamEntityName)
    teamEntityName = @"FSPTeam";

    return teamEntityName;
}

- (void)updateTeamRecordsWithDictionary:(NSDictionary *)teamRecordsDict;
{
    self.conferenceName = [teamRecordsDict fsp_objectForKey:FSPTeamConferenceNameKey defaultValue:@"--"];
    self.divisionName = [teamRecordsDict fsp_objectForKey:FSPTeamDivisionNameKey defaultValue:@"--"];
    self.clinched = [teamRecordsDict fsp_objectForKey:@"clinched" expectedClass:NSString.class];

    //Update stats
    NSArray *stats = [teamRecordsDict objectForKey:@"stats"];

	switch (self.viewType) {
		case FSPNCAABViewType:
        case FSPNCAAWBViewType:
        case FSPBasketballViewType:
			[self updateTeamStatsWithBasketballArray:stats];
			break;
		case FSPNFLViewType:
		case FSPNCAAFViewType:
			[self updateTeamStatsWithFootballArray:stats];
			break;
		case FSPBaseballViewType:
			[self updateTeamStatsWithBaseballArray:stats];
			break;
		case FSPSoccerViewType:
			[self updateTeamStatsWithSoccerArray:stats];
			break;
		case FSPHockeyViewType:
			[self updateTeamStatsWithHockeyArray:stats];
			break;
		default:
			break;
	}


    // Update records: iterate the records and populate the correct one.
    NSArray *records = [teamRecordsDict fsp_objectForKey:@"records" expectedClass:NSArray.class];
    FSPRecordObjectValidator *validator = [[FSPRecordObjectValidator alloc] init];
    for (NSDictionary *record in records) {
        
        NSDictionary *validatedRecord = [validator validateDictionary:record error:nil];
        
        NSString *recordTypeString = [validatedRecord objectForKey:FSPTeamRecordTypeKey];
        if ([recordTypeString isEqualToString:FSPOverallRecordKey])
            [self.overallRecord populateWithDictionary:validatedRecord];
        else if ([recordTypeString isEqualToString:FSPHomeRecordKey])
            [self.homeRecord populateWithDictionary:record];
        else if ([recordTypeString isEqualToString:FSPAwayRecordKey])
            [self.awayRecord populateWithDictionary:record];
        else if ([recordTypeString isEqualToString:FSPConferenceRecordKey])
            [self.conferenceRecord populateWithDictionary:record];
        else if ([recordTypeString isEqualToString:FSPDivisionRecordKey])
            [self.divisionRecord populateWithDictionary:record];
        else if ([recordTypeString isEqualToString:FSPLastTenRecordKey])
            [self.lastTenGamesRecord populateWithDictionary:record];
        
        // workaround for NCAA not always returning a win percentage
        if (self.winPercent == nil) {
            self.winPercent = [NSString stringWithFormat:@"%.3f", self.overallRecord.wins.doubleValue / (self.overallRecord.ties.doubleValue + self.overallRecord.wins.doubleValue + self.overallRecord.losses.doubleValue)];
        }
    }
}

- (void)updateTeamStatsWithBasketballArray:(NSArray *)statsArray;
{
    for (NSDictionary *stat in statsArray) {
        NSString *statType = [stat fsp_objectForKey:@"stat" defaultValue:@""];
        NSString *theStat = [stat fsp_objectForKey:FSPValueKey defaultValue:@""];
        if ([statType isEqualToString:@"streak"]) {
            self.streak = theStat;
            self.streakType = [[stat fsp_objectForKey:@"labelCode" defaultValue:@""] lowercaseString];
        } else if ([statType isEqualToString:@"PPG"]) {
            self.pointsPerGame = theStat;
        } else if ([statType isEqualToString:@"RPG"]) {
            self.reboundsPerGame = theStat;
        } else if ([statType isEqualToString:@"TOPG"]) {
            self.turnoversPerGame =  theStat;
        } else if ([statType isEqualToString:@"WP"]) {
            self.winPercent = theStat;
        } else if ([statType isEqualToString:@"DGB"]) {
            self.divisionGamesBack = theStat;
        } else if ([statType isEqualToString:@"CGB"]) {
            self.conferenceGamesBack = theStat;
        }  else if ([statType isEqualToString:@"SEED"]) {
            self.conferenceRanking = @([theStat intValue]);
        }
    }
}

- (void)updateTeamStatsWithFootballArray:(NSArray *)statsArray;
{
    for (NSDictionary *stat in statsArray) {
        NSString *statType = [stat fsp_objectForKey:@"stat" defaultValue:@""];
        NSString *theStat = [stat fsp_objectForKey:FSPValueKey defaultValue:@""];
		// it seems that empty stats are being passed as empty arrays, rather than empty strings. work around this. (it was causing a crash)
		if ([theStat isKindOfClass:[NSArray class]] && [(NSArray *)theStat count] == 0) {
			theStat = nil;
		}

        if ([statType isEqualToString:@"streak"]) {
            self.streak = theStat;
            self.streakType = [stat fsp_objectForKey:@"labelCode" defaultValue:@""];
        } else if ([statType isEqualToString:@"PF"]) {
            self.pointsFor = theStat;
        } else if ([statType isEqualToString:@"PA"]) {
            self.pointsAgainst = theStat;
        } else if ([statType isEqualToString:@"YPG"]) {
            self.yardsPerGame = theStat;
        } else if ([statType isEqualToString:@"OYPG"]) {
            self.opponentYardsPerGame = theStat;
        } else if ([statType isEqualToString:@"TOPG"]) {
            self.turnoversPerGame = theStat;
        } else if ([statType isEqualToString:@"WP"]) {
            self.winPercent = theStat;
        }
    }
}

- (void)updateTeamStatsWithBaseballArray:(NSArray *)statsArray;
{
    for (NSDictionary *stat in statsArray) {
        NSString *statType = [stat fsp_objectForKey:@"stat" defaultValue:@""];
        NSString *theStat = [stat fsp_objectForKey:FSPValueKey defaultValue:@""];
        
        if ([statType isEqualToString:@"streak"]) {
            self.streak = theStat;
            self.streakType = [stat fsp_objectForKey:@"labelCode" defaultValue:@""];
        } else if ([statType isEqualToString:@"DGB"]) {
            self.divisionGamesBack = theStat;
        } else if ([statType isEqualToString:@"WCGB"]) {
            self.wildCardGamesBack = theStat;
        } else if ([statType isEqualToString:@"WP"]) {
            self.winPercent = theStat;
        }
    }
}

- (void)updateTeamStatsWithSoccerArray:(NSArray *)statsArray;
{
    for (NSDictionary *stat in statsArray) {
        NSString *statType = [stat fsp_objectForKey:@"stat" defaultValue:@""];
        NSString *theStat = [stat fsp_objectForKey:FSPValueKey defaultValue:@""];
        
        if ([statType isEqualToString:@"streak"]) {
            self.streak = theStat;
            self.streakType = [stat fsp_objectForKey:@"labelCode" defaultValue:@""];
        } else if ([statType isEqualToString:@"SF"]) {
            self.shots = theStat;
        } else if ([statType isEqualToString:@"SOG"]) {
            self.shotsOnGoal = theStat;
        } else if ([statType isEqualToString:@"YC"]) {
            self.yellowCards = theStat;
        } else if ([statType isEqualToString:@"RC"]) {
            self.redCards = theStat;
        } else if ([statType isEqualToString:@"FS"]) {
            self.fouls = theStat;
        } else if ([statType isEqualToString:@"GF"]) {
            self.goals = theStat;
        } else if ([statType isEqualToString:@"GP"]) {
            self.gamesPlayed = theStat;
        } else if ([statType isEqualToString:@"GA"]) {
            self.goalsAgainst = theStat;
        } else if ([statType isEqualToString:@"GD"]) {
            self.goalDifferential = theStat;
        } else if ([statType isEqualToString:@"PTS"]) {
            self.points = theStat;
        }
    }
}

- (void)updateTeamStatsWithHockeyArray:(NSArray *)statsArray;
{
    for (NSDictionary *stat in statsArray) {
        NSString *statType = [stat fsp_objectForKey:@"stat" defaultValue:@""];
        NSString *theStat = [stat fsp_objectForKey:FSPValueKey defaultValue:@""];
        
        if ([statType isEqualToString:@"streak"]) {
            self.streak = theStat;
            self.streakType = [stat fsp_objectForKey:@"labelCode" defaultValue:@""];
        } else if ([statType isEqualToString:@"PTS"]) {
            self.points = theStat;
        } else if ([statType isEqualToString:@"WP"]) {
            self.winPercent = theStat;
        } else if ([statType isEqualToString:@"SEED"]) {
            self.conferenceRanking = @([theStat intValue]);
        } else if ([statType isEqualToString:@"ROW"]) {
            self.winTotal = theStat;
        } else if ([statType isEqualToString:@"PPP"]) {
            self.powerPlayPercentage = theStat;
        } else if ([statType isEqualToString:@"PKP"]) {
            self.penaltyKillPercentage = theStat;
        } else if ([statType isEqualToString:@"GPG"]) {
            self.goalsPerGame = theStat;
        } else if ([statType isEqualToString:@"GAPG"]) {
            self.goalsAllowedPerGame = theStat;
        } else if ([statType isEqualToString:@"SPG"]) {
            self.shotsPerGame = theStat;
        } else if ([statType isEqualToString:@"SAPG"]) {
            self.shotsAgainstPerGame = theStat;
        }
    }
}

- (void)updateTeamRankingsWithDictionary:(NSDictionary *)teamRankingsDictionary primaryRankingPoll:(NSString *)primaryPoll
{
    NSString *pollType = [teamRankingsDictionary fsp_objectForKey:FSPTeamRankingPollTypeKey expectedClass:NSString.class];
//    NSDictionary *rankingDictionary = [teamRankingsDictionary fsp_objectForKey:FSPTeamRankingRankingDictionaryKey expectedClass:NSDictionary.class];
//    FSPRecordObjectValidator *validator = [[FSPRecordObjectValidator alloc] init];
        
//        NSDictionary *validatedRecord = [validator validateDictionary:record error:nil];
        
        if ([pollType isEqualToString:FSPTeamRankingAPPollTypeKey])
            [self.apRanking populateWithDictionary:teamRankingsDictionary];
        else if ([pollType isEqualToString:FSPTeamRankingUsaTodayPollTypeKey])
            [self.usaTodayRanking populateWithDictionary:teamRankingsDictionary];
        else if ([pollType isEqualToString:FSPTeamRankingPowerTypeKey])
            [self.powerRanking populateWithDictionary:teamRankingsDictionary];
 
    if ([primaryPoll isEqualToString:self.apRanking.pollType]) {
        self.primaryRank = self.apRanking.rank;
    } else if ([primaryPoll isEqualToString:self.usaTodayRanking.pollType]) {
        self.primaryRank = self.usaTodayRanking.rank;
    } else if ([primaryPoll isEqualToString:self.powerRanking.pollType]) {
        self.primaryRank = self.usaTodayRanking.rank;
    }
}

- (UIColor *)teamColor; 
{
    NSString *hex = self.colorInHex;
    return [UIColor fsp_colorWithHexString:hex];
}

- (UIColor *)alternateTeamColor;
{
    NSString *hex = self.alternateColorInHex;
    return [UIColor fsp_colorWithHexString:hex];
}

- (NSString *)streakDisplayString;
{
    if(!self.streakType || !self.streak)
        return @"--";

    NSString *streakTypeDisplayString = @"";
    if([self.streakType isEqualToString:FSPStreakTypeLosing])
        streakTypeDisplayString = @"L";
    else if([self.streakType isEqualToString:FSPStreakTypeWinning])
        streakTypeDisplayString = @"W";

    return [NSString stringWithFormat:@"%@%@", streakTypeDisplayString, self.streak];
}

- (NSString *)shortNameDisplayString;
{
    if ([self.nickname isEqualToString:@""] && [self.name isEqualToString:@""])
        return @"-";
    
   	switch (self.viewType) {
        case FSPHockeyViewType:
        case FSPBaseballViewType:
        case FSPBasketballViewType:
        case FSPNFLViewType:
            if (self.nickname.length == 0)
                return self.name;
            return self.nickname;
            break;
        case FSPNCAABViewType:
        case FSPNCAAFViewType:
        case FSPNCAAWBViewType:
        case FSPSoccerViewType:
            return self.name;
            break;
		default:
            if ([self.name isEqualToString:@""])
                return self.nickname;
            return self.name;
			break;
	}
}

- (NSString *)longNameDisplayString;
{
    if ([self.nickname isEqualToString:@""] && [self.name isEqualToString:@""])
        return @"-";
    
   	switch (self.viewType) {
        case FSPHockeyViewType:
        case FSPBaseballViewType:
        case FSPBasketballViewType:
        case FSPNFLViewType:
            return [NSString stringWithFormat:@"%@ %@", self.name, self.nickname];
            break;
        case FSPNCAABViewType:
        case FSPNCAAFViewType:
        case FSPNCAAWBViewType:
        case FSPSoccerViewType:
            return self.name;
            break;
		default:
            if (self.name.length == 0)
                return self.nickname;
            return self.name;
			break;
	}
}

#pragma mark - Fetched Properties
- (FSPTeamRecord *)teamRecordWithType:(NSString *)type;
{
    FSPTeamRecord *recordToReturn;
    
    for (FSPTeamRecord *record in self.records) {
        if ([record.type isEqualToString:type]) {
            recordToReturn = record;
            break;
        }
    }
    
    if (recordToReturn == nil) {
        recordToReturn = [NSEntityDescription insertNewObjectForEntityForName:@"FSPTeamRecord" inManagedObjectContext:self.managedObjectContext];
        recordToReturn.type = type;
        recordToReturn.team = self;
    }
    
    return recordToReturn;
}

- (FSPTeamRanking *)teamRankingWithType:(NSString *)type {
    FSPTeamRanking *rankingToReturn;
    for (FSPTeamRanking *ranking in self.rankings) {
        if ([ranking.pollType isEqualToString:type]) {
            rankingToReturn = ranking;
            break;
        }
    }
    
    if (rankingToReturn == nil) {
        rankingToReturn = [NSEntityDescription insertNewObjectForEntityForName:@"FSPTeamRanking" inManagedObjectContext:self.managedObjectContext];
        rankingToReturn.pollType = type;
        rankingToReturn.team = self;
    }
    
    return rankingToReturn;
}

- (FSPTeamRanking *)apRanking
{
    return [self teamRankingWithType:FSPTeamRankingAPPollTypeKey];
}

- (FSPTeamRanking *)usaTodayRanking
{
    return [self teamRankingWithType:FSPTeamRankingUsaTodayPollTypeKey];
}

- (FSPTeamRanking *)powerRanking
{
    return [self teamRankingWithType:FSPTeamRankingPowerTypeKey];
}

- (FSPTeamRecord *)overallRecord;
{
    return [self teamRecordWithType:FSPOverallRecordKey];
}

- (FSPTeamRecord *)homeRecord;
{
    return [self teamRecordWithType:FSPHomeRecordKey];
}

- (FSPTeamRecord *)awayRecord;
{
    return [self teamRecordWithType:FSPAwayRecordKey];
}

- (FSPTeamRecord *)conferenceRecord;
{
    return [self teamRecordWithType:FSPConferenceRecordKey];
}

- (FSPTeamRecord *)divisionRecord;
{
    return [self teamRecordWithType:FSPDivisionRecordKey];
}

- (FSPTeamRecord *)lastTenGamesRecord;
{
    return [self teamRecordWithType:FSPLastTenRecordKey];
}
@end
