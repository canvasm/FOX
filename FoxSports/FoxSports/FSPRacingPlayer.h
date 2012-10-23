//
//  FSPRacingPlayer.h
//  FoxSports
//
//  Created by Matthew Fay on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPPlayer.h"
#import "FSPRacingSeasonStats.h"

@class FSPRacingEvent;

@interface FSPRacingPlayer : FSPPlayer

//Driver Stats
@property (nonatomic, retain) NSNumber * playerNumber;
@property (nonatomic, retain) NSNumber * raceStartPosition;
@property (nonatomic, retain) NSString * vehicleDescription;

//Race Stats
@property (nonatomic, retain) NSNumber * qualifyingSpeed;
@property (nonatomic, retain) NSString * qualifyingTime;
@property (nonatomic, retain) NSNumber * positionInRace;
@property (nonatomic, retain) NSNumber * positionInClass;
@property (nonatomic, retain) NSNumber * topSpeed;
@property (nonatomic, retain) NSString * intervalBehindLeader;
@property (nonatomic, retain) NSString * intervalBehindLeaderType;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * bestLapTime;
@property (nonatomic, retain) NSNumber * laps;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSNumber * bonus;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * winnings;

@property (nonatomic, retain) NSSet * seasons;
@property (nonatomic, retain) FSPRacingEvent *race;

- (NSString *)winningsInCurrencyFormat;

@end

@interface FSPRacingPlayer (CoreDataGeneratedAccessors)

- (void)addSeasonsObject:(FSPRacingSeasonStats *)season;
- (void)removeSeasonsObject:(FSPRacingSeasonStats *)season;
- (void)addSeasons:(NSSet *)seasons;
- (void)removeSeasons:(NSSet *)seasons;

@end