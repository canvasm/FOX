//
//  FSPGame.h
//  FoxSports
//
//  Created by Laura Savino on 2/4/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPEvent.h"

@class FSPGamePeriod, FSPTeam, FSPGameOdds, FSPTeamPlayer, FSPGamePlayByPlayItem;

@interface FSPGame : FSPEvent

/**
 * The unique identifier of the winning team; updated after the game has completed.
 */
@property (nonatomic, retain) NSString * winningTeamIdentifier;

@property (nonatomic, retain) NSString * homeTeamIdentifier;
@property (nonatomic, retain) NSNumber * homeTeamScore;
@property (nonatomic, retain) NSString * awayTeamIdentifier;
@property (nonatomic, retain) NSNumber * awayTeamScore;
@property (nonatomic, retain) FSPTeam *awayTeam;
@property (nonatomic, retain) FSPTeam *homeTeam;
@property (nonatomic, retain) NSOrderedSet *periods;

@property (nonatomic, retain) NSSet *homeTeamPlayers;
@property (nonatomic, retain) NSSet *awayTeamPlayers;

@property (nonatomic, retain) NSNumber *homeTeamLiveEngineID;
@property (nonatomic, retain) NSNumber *awayTeamLiveEngineID;

@property (nonatomic, retain) NSNumber *homeTimeoutsRemaining;
@property (nonatomic, retain) NSNumber *awayTimeoutsRemaining;

@property (readonly) UIColor *homeTeamColor;
@property (readonly) UIColor *awayTeamColor;

/**
 The odds object for this event.
 */
@property (nonatomic, retain) FSPGameOdds *odds;

@property (nonatomic, retain) NSOrderedSet *playByPlayItems;

/*!
 @abstract Used to determine if enough data is available for a matchup. Defaults to NO.
 @return Boolean available/not available
 @discussion This method should be overridden by all subclasses
 */
- (BOOL)matchupAvailable;

- (NSUInteger)maxTimeouts;

@end

@interface FSPGame (CoreDataGeneratedAccessors)

- (void)insertObject:(FSPGamePeriod *)value inPeriodsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPeriodsAtIndex:(NSUInteger)idx;
- (void)insertPeriods:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePeriodsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPeriodsAtIndex:(NSUInteger)idx withObject:(FSPGamePeriod *)value;
- (void)replacePeriodsAtIndexes:(NSIndexSet *)indexes withPeriods:(NSArray *)values;
- (void)addPeriodsObject:(FSPGamePeriod *)value;
- (void)removePeriodsObject:(FSPGamePeriod *)value;
- (void)addPeriods:(NSOrderedSet *)values;
- (void)removePeriods:(NSOrderedSet *)values;

- (void)addHomeTeamPlayersObject:(FSPTeamPlayer *)player;
- (void)removeHomeTeamPlayersObject:(FSPTeamPlayer *)player;
- (void)addHomeTeamPlayers:(NSSet *)players;
- (void)removeHomeTeamPlayers:(NSSet *)players;

- (void)addAwayTeamPlayersObject:(FSPTeamPlayer *)player;
- (void)removeAwayTeamPlayersObject:(FSPTeamPlayer *)player;
- (void)addAwayTeamPlayers:(NSSet *)players;
- (void)removeAwayTeamPlayers:(NSSet *)players;

- (void)insertObject:(FSPGamePlayByPlayItem *)value inPlayByPlayItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPlayByPlayItemsAtIndex:(NSUInteger)idx;
- (void)insertPlayByPlayItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePlayByPlayItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPlayByPlayItemsAtIndex:(NSUInteger)idx withObject:(FSPGamePlayByPlayItem *)value;
- (void)replacePlayByPlayItemsAtIndexes:(NSIndexSet *)indexes withPlayByPlayItems:(NSArray *)values;
- (void)addPlayByPlayItemsObject:(FSPGamePlayByPlayItem *)pbp;
- (void)removePlayByPlayItemsObject:(FSPGamePlayByPlayItem *)pbp;
- (void)addPlayByPlayItems:(NSOrderedSet *)pbps;
- (void)removePlayByPlayItems:(NSOrderedSet *)pbps;

- (FSPGamePlayByPlayItem *)gameStatePlayByPlayItem;
@end
