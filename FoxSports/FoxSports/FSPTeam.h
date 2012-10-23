//
//  FSPTeam.h
//  FoxSports
//
//  Created by Chase Latta on 2/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPOrganization.h"

@class FSPGame, FSPPlayer, FSPTeamRecord, FSPGamePlayByPlayItem;
@class FSPSoccerSub, FSPSoccerCard, FSPSoccerGoal;
@class FSPTeamRanking;

/**
 A string indicating that the team has clinched a playoff spot in NBA.
 */
extern NSString * const FSPTeamClinchedPlayoffs;

/**
 A string indicating that an NBA team is first in their division.
 */
extern NSString * const FSPTeamDivisionFirst;

/**
 A string indicating that an NBA team is first in their conference.
 */
extern NSString * const FSPTeamConferenceFirst;

/// Dictionary Keys
extern NSString * const FSPTeamOrganizationIdentifierKey;
extern NSString * const FSPTeamConferenceNameKey;
extern NSString * const FSPTeamDivisionNameKey;

@interface FSPTeam : FSPOrganization

@property (nonatomic, retain) NSString *sportType;
@property (nonatomic, retain) NSString *abbreviation;
@property (nonatomic, retain) NSNumber *conferenceRanking;
@property (nonatomic, retain) NSString *divisionRanking;
@property (nonatomic, retain) NSString *streak;
@property (nonatomic, retain) NSString *streakType;
@property (nonatomic, retain) NSString *conferenceName;
@property (nonatomic, retain) NSString *winPercent;
@property (nonatomic, retain) NSSet *awayGames;
@property (nonatomic, retain) NSSet *homeGames;
@property (nonatomic, retain) NSSet *records;
@property (nonatomic, retain) NSSet *playByPlays;
@property (nonatomic, retain) NSString *conferenceGamesBack;
@property (nonatomic, retain) NSString *divisionGamesBack;
@property (nonatomic, retain) NSString *wildCardGamesBack;
@property (nonatomic, retain) NSString *colorInHex;
@property (nonatomic, retain) NSString *alternateColorInHex;
@property (nonatomic, retain) NSString *teamColorNameTag;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSSet *organizations;
@property (nonatomic, strong) NSNumber * isEventOnly;

@property (nonatomic, retain) NSString *pointsPerGame;
@property (nonatomic, retain) NSString *reboundsPerGame;
@property (nonatomic, retain) NSString *turnoversPerGame;

@property (nonatomic, retain) NSString *yardsPerGame;
@property (nonatomic, retain) NSString *opponentYardsPerGame;
@property (nonatomic, retain) NSString *pointsAgainst;
@property (nonatomic, retain) NSString *pointsFor;

//Soccer
@property (nonatomic, retain) NSString *shots;
@property (nonatomic, retain) NSString *shotsOnGoal;
@property (nonatomic, retain) NSString *yellowCards;
@property (nonatomic, retain) NSString *redCards;
@property (nonatomic, retain) NSString *fouls;
@property (nonatomic, retain) NSString *goals;
@property (nonatomic, retain) NSString *goalsAgainst;
@property (nonatomic, retain) NSString *gamesPlayed;
@property (nonatomic, retain) NSString *goalDifferential;

//Hockey
@property (nonatomic, retain) NSString *points;
@property (nonatomic, retain) NSString *winTotal;
@property (nonatomic, retain) NSString *powerPlayPercentage;
@property (nonatomic, retain) NSString *penaltyKillPercentage;
@property (nonatomic, retain) NSString *goalsPerGame;
@property (nonatomic, retain) NSString *goalsAllowedPerGame;
@property (nonatomic, retain) NSString *shotsPerGame;
@property (nonatomic, retain) NSString *shotsAgainstPerGame;

// Team  rankings
- (void)updateTeamRankingsWithDictionary:(NSDictionary *)teamRankingsDictionary primaryRankingPoll:(NSString *)primaryPoll;
@property (nonatomic, retain) NSSet *rankings;
@property (nonatomic, retain) FSPTeamRanking *apRanking;
@property (nonatomic, retain) FSPTeamRanking *usaTodayRanking;
@property (nonatomic, retain) FSPTeamRanking *powerRanking;
@property (nonatomic, retain) NSNumber *primaryRank;

// NFL rankings
@property (nonatomic, retain) NSString *winsRankingString;
@property (nonatomic, retain) NSString *yardsPerGameRankingString;
@property (nonatomic, retain) NSString *opponentYardsPerGameRankingString;
@property (nonatomic, retain) NSString *turnoversPerGameRankingString;

@property (nonatomic, strong, readonly) UIColor *teamColor;
@property (nonatomic, strong, readonly) UIColor *alternateTeamColor;

/**
 A string indicating what status the team has clinched if any.
 */
@property (nonatomic, retain) NSString *clinched;

/**
 The name of the teams division.
 */
@property (nonatomic, retain) NSString *divisionName;

/**
 * Returns the entity name for the team associated with a given sport type.
 *
 * If sportType is nil or if no team entity name is found, default return value is
 * @"FSPTeam".
 */
+ (NSString *)teamEntityNameForSportType:(NSString *)sportType;

- (void)updateTeamRecordsWithDictionary:(NSDictionary *)teamRecordsDict;

@property (nonatomic, retain, readonly) FSPTeamRecord *overallRecord;
@property (nonatomic, retain, readonly) FSPTeamRecord *homeRecord;
@property (nonatomic, retain, readonly) FSPTeamRecord *awayRecord;
@property (nonatomic, retain, readonly) FSPTeamRecord *conferenceRecord;
@property (nonatomic, retain, readonly) FSPTeamRecord *divisionRecord;
@property (nonatomic, retain, readonly) FSPTeamRecord *lastTenGamesRecord;

//Soccer Specific References
@property (nonatomic, retain) NSSet * soccerCards;
@property (nonatomic, retain) NSSet * soccerGoals;
@property (nonatomic, retain) NSSet * soccerSubs;

/**
 * View utility method: Returns a string appropriate for displaying the team's streak, e.g., "Won 3".
 */
- (NSString *)streakDisplayString;

@end

@interface FSPTeam (CoreDataGeneratedAccessors)

- (void)addOrganizationsObject:(FSPOrganization *)value;
- (void)removeOrganizationsObject:(FSPOrganization *)value;
- (void)addOrganizations:(NSSet *)values;
- (void)removeOrganizationss:(NSSet *)values;

- (void)addAwayGamesObject:(FSPGame *)value;
- (void)removeAwayGamesObject:(FSPGame *)value;
- (void)addAwayGames:(NSSet *)values;
- (void)removeAwayGames:(NSSet *)values;

- (void)addHomeGamesObject:(FSPGame *)value;
- (void)removeHomeGamesObject:(FSPGame *)value;
- (void)addHomeGames:(NSSet *)values;
- (void)removeHomeGames:(NSSet *)values;

- (void)addRecordsObject:(FSPTeamRecord *)record;
- (void)removeRecordsObject:(FSPTeamRecord *)record;
- (void)addRecords:(NSSet *)records;
- (void)removeRecords:(NSSet *)records;

- (void)addPlayByPlaysObject:(FSPGamePlayByPlayItem *)playByPlays;
- (void)removePlayByPlaysObject:(FSPGamePlayByPlayItem *)playByPlays;
- (void)addPlayByPlays:(NSSet *)playByPlays;
- (void)removePlayByPlays:(NSSet *)playByPlays;

- (void)addSoccerCardsObject:(FSPSoccerCard *)card;
- (void)removeSoccerCardsObject:(FSPSoccerCard *)card;
- (void)addSoccerCards:(NSSet *)cards;
- (void)removeSoccerCards:(NSSet *)cards;

- (void)addSoccerGoalsObject:(FSPSoccerGoal *)goal;
- (void)removeSoccerGoalsObject:(FSPSoccerGoal *)goal;
- (void)addSoccerGoals:(NSSet *)goals;
- (void)removeSoccerGoals:(NSSet *)goals;

- (void)addSoccerSubsObject:(FSPSoccerSub *)sub;
- (void)removeSoccerSubsObject:(FSPSoccerSub *)sub;
- (void)addSoccerSubs:(NSSet *)sub;
- (void)removeSoccerSubs:(NSSet *)sub;

- (void)addRankingsObject:(FSPTeamRanking *)sub;
- (void)removeRankingsObject:(FSPTeamRanking *)sub;
- (void)addRankings:(NSSet *)rankings;
- (void)removeRankings:(NSSet *)rankings;

@end
