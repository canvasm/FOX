//
//  FSPTeamRanking.h
//  FoxSports
//
//  Created by Joshua Dubey on 9/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const FSPTeamRankingPollNameKey;
extern NSString * const FSPTeamRankingPollTypeKey;
extern NSString * const FSPTeamRankingRankKey;
extern NSString * const FSPTeamRankingPreviousRankKey;
extern NSString * const FSPTeamRankingDroppedKey;
extern NSString * const FSPTeamRankingPointsKey;
extern NSString * const FSPTeamRankingRankedTeamsKey;
extern NSString * const FSPTeamRankingRankingDictionaryKey;

extern NSString * const FSPTeamRankingAPPollTypeKey;
extern NSString * const FSPTeamRankingUsaTodayPollTypeKey;
extern NSString * const FSPTeamRankingPowerTypeKey;

@class FSPTeam;

@interface FSPTeamRanking : NSManagedObject

@property (nonatomic, retain) NSString * pollName;
@property (nonatomic, retain) NSString * pollType;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSNumber * isRanked;
@property (nonatomic, retain) NSNumber * previousRank;
@property (nonatomic, retain) NSNumber * dropped;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) FSPTeam * team;

- (void)populateWithDictionary:(NSDictionary *)rankingDictionary;

@end
