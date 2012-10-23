//
//  FSPSoccerGame.h
//  FoxSports
//
//  Created by Matthew Fay on 7/9/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPGame.h"

@class FSPSoccerSub, FSPSoccerCard, FSPSoccerGoal;

@interface FSPSoccerGame : FSPGame

@property (nonatomic, retain) NSNumber * homeGoalsNum;
@property (nonatomic, retain) NSNumber * homeAssists;
@property (nonatomic, retain) NSNumber * homeShots;
@property (nonatomic, retain) NSNumber * homeShotsOnGoal;
@property (nonatomic, retain) NSNumber * homeSaves;
@property (nonatomic, retain) NSNumber * homeCornerKicks;
@property (nonatomic, retain) NSNumber * homeFoulsCommitted;
@property (nonatomic, retain) NSNumber * homeYellowCards;
@property (nonatomic, retain) NSNumber * homeRedCards;
@property (nonatomic, retain) NSNumber * awayAssists;
@property (nonatomic, retain) NSNumber * awayCornerKicks;
@property (nonatomic, retain) NSNumber * awayFoulsCommitted;
@property (nonatomic, retain) NSNumber * awayGoalsNum;
@property (nonatomic, retain) NSNumber * awayRedCards;
@property (nonatomic, retain) NSNumber * awaySaves;
@property (nonatomic, retain) NSNumber * awayShots;
@property (nonatomic, retain) NSNumber * awayShotsOnGoal;
@property (nonatomic, retain) NSNumber * awayYellowCards;
@property (nonatomic, retain) NSNumber * aditionalMinutes;

@property (nonatomic, retain) NSSet * homeCards;
@property (nonatomic, retain) NSSet * homeGoals;
@property (nonatomic, retain) NSSet * homeSubs;
@property (nonatomic, retain) NSSet * awayCards;
@property (nonatomic, retain) NSSet * awayGoals;
@property (nonatomic, retain) NSSet * awaySubs;

@property (nonatomic, retain) NSNumber * coverageLevel;

@end

@interface FSPSoccerGame (CoreDataGeneratedAccessors)

- (void)addHomeCardsObject:(FSPSoccerCard *)card;
- (void)removeHomeCardsObject:(FSPSoccerCard *)card;
- (void)addHomeCards:(NSSet *)cards;
- (void)removeHomeCards:(NSSet *)cards;

- (void)addHomeGoalsObject:(FSPSoccerGoal *)goal;
- (void)removeHomeGoalsObject:(FSPSoccerGoal *)goal;
- (void)addHomeGoals:(NSSet *)goals;
- (void)removeHomeGoals:(NSSet *)goals;

- (void)addHomeSubsObject:(FSPSoccerSub *)sub;
- (void)removeHomeSubsObject:(FSPSoccerSub *)sub;
- (void)addHomeSubs:(NSSet *)sub;
- (void)removeHomeSubs:(NSSet *)sub;

- (void)addAwayCardsObject:(FSPSoccerCard *)card;
- (void)removeAwayCardsObject:(FSPSoccerCard *)card;
- (void)addAwayCards:(NSSet *)cards;
- (void)removeAwayCards:(NSSet *)cards;

- (void)addAwayGoalsObject:(FSPSoccerGoal *)goal;
- (void)removeAwayGoalsObject:(FSPSoccerGoal *)goal;
- (void)addAwayGoals:(NSSet *)goals;
- (void)removeAwayGoals:(NSSet *)goals;

- (void)addAwaySubsObject:(FSPSoccerSub *)sub;
- (void)removeAwaySubsObject:(FSPSoccerSub *)sub;
- (void)addAwaySubs:(NSSet *)sub;
- (void)removeAwaySubs:(NSSet *)sub;

@end