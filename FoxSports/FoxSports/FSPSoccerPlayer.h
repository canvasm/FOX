//
//  FSPSoccerPlayer.h
//  FoxSports
//
//  Created by Matthew Fay on 7/9/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPTeamPlayer.h"

@class FSPSoccerSub, FSPSoccerGoal, FSPSoccerCard;

@interface FSPSoccerPlayer : FSPTeamPlayer

//Field Player Stats
@property (nonatomic, retain) NSNumber * minutesPlayed;
@property (nonatomic, retain) NSNumber * shots;
@property (nonatomic, retain) NSNumber * shotsOnGoal;
@property (nonatomic, retain) NSNumber * foulsCommitted;
@property (nonatomic, retain) NSNumber * foulsSuffered;

//Goalie Stats
@property (nonatomic, retain) NSNumber * goalsAllowed;
@property (nonatomic, retain) NSNumber * shotsAgainst;
@property (nonatomic, retain) NSNumber * shotsOnGoalAgainst;

//Relationships
@property (nonatomic, retain) NSSet * assists;
@property (nonatomic, retain) NSSet * goals;
@property (nonatomic, retain) FSPSoccerSub * subbedIn;
@property (nonatomic, retain) FSPSoccerSub * subbedOut;
@property (nonatomic, retain) NSSet * cards;

@end

@interface FSPSoccerPlayer (CoreDataGeneratedAccessors)

- (void)addAssistsObject:(FSPSoccerGoal *)assist;
- (void)removeAssistsObject:(FSPSoccerGoal *)assist;
- (void)addAssists:(NSSet *)assists;
- (void)removeAssists:(NSSet *)assists;

- (void)addGoalsObject:(FSPSoccerGoal *)goal;
- (void)removeGoalsObject:(FSPSoccerGoal *)goal;
- (void)addGoals:(NSSet *)goals;
- (void)removeGoals:(NSSet *)goals;

- (void)addCardsObject:(FSPSoccerCard *)card;
- (void)removeCardsObject:(FSPSoccerCard *)card;
- (void)addCards:(NSSet *)cards;
- (void)removeCards:(NSSet *)cards;

@end