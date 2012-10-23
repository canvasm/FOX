//
//  FSPGamePlayByPlayItem.h
//  FoxSports
//
//  Created by Matthew Fay on 3/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPGame;
@class FSPTeam;
@class FSPBaseballPlayer;
@class FSPPitchEvent;

@interface FSPGamePlayByPlayItem : NSManagedObject

//used by all
@property (nonatomic, retain) NSNumber * awayScore;
@property (nonatomic, retain) NSNumber * correction;
@property (nonatomic, retain) NSNumber * homeScore;
@property (nonatomic, retain) NSNumber * minute;
@property (nonatomic, retain) NSNumber * period;
@property (nonatomic, retain) NSNumber * adjustedPeriodValue;
@property (nonatomic, retain) NSNumber * isPlaceholder;
@property (nonatomic, retain) NSNumber * pointsScored;
@property (nonatomic, retain) NSNumber * possessionIdentifier;
@property (nonatomic, retain) NSNumber * second;
@property (nonatomic, retain) NSNumber * sequenceNumber;
@property (nonatomic, retain) NSString * summaryPhrase;
@property (nonatomic, retain) NSString * abbreviatedSummary;

@property (nonatomic, retain) FSPGame * game;
@property (nonatomic, retain) FSPTeam * team;

//NFL specific
@property (nonatomic, retain) NSNumber * possessionChange;
@property (nonatomic, retain) NSString * possessionChangePhrase;
@property (nonatomic, retain) NSNumber * down;
@property (nonatomic, retain) NSNumber * yardsToGo;
@property (nonatomic, retain) NSNumber * yardsFromGoal;

//MLB specific
@property (nonatomic, retain) NSNumber * baseRunners;
@property (nonatomic, retain) NSNumber * outOccured;
@property (nonatomic, retain) NSNumber * outs;
@property (nonatomic, retain) NSString * topBottom;

//Soccer
@property (nonatomic, retain) NSNumber * substitution;

//Hockey
@property (nonatomic, retain) NSNumber * penalty;

//GameEvent
@property (nonatomic, retain) NSString * eventCode;
@property (nonatomic, retain) NSNumber * battingSlot;
@property (nonatomic, retain) NSString * batType;
@property (nonatomic, retain) NSNumber * distanceHit;
@property (nonatomic, retain) NSString * directionHit;
@property (nonatomic, retain) NSNumber * inningHits;
@property (nonatomic, retain) NSNumber * inningRuns;
@property (nonatomic, retain) NSNumber * inningErrors;

@property (nonatomic, retain) FSPBaseballPlayer * currentPlayerHome;
@property (nonatomic, retain) FSPBaseballPlayer * currentPlayerAway;
@property (nonatomic, retain) NSOrderedSet * pitches;

- (void)populateWithDictionary:(NSDictionary *)playByPlayDict withGame:(FSPGame *)game;
- (NSString *)periodTitle;
- (UIColor *)periodBackgroundColor;
- (NSString *)shortPeriodTitle;
- (NSString *)eventPBPString;
- (NSNumber *)adjustedPeriod;
- (void)populateWithGameEventDictionary:(NSDictionary *)GEDict inContext:(NSManagedObjectContext *)context;

//so far NFL only
- (void)populateWithGameStateDictionary:(NSDictionary *)gameState;
- (NSString *)yardsFromGoalString;

@end

@interface FSPGamePlayByPlayItem (CoreDataGeneratedAccessors)
- (void)insertObject:(FSPPitchEvent *)value inPitchesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPitchesAtIndex:(NSUInteger)idx;
- (void)insertPitches:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePitchesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPitchesAtIndex:(NSUInteger)idx withObject:(FSPPitchEvent *)value;
- (void)replacePitchesAtIndexes:(NSIndexSet *)indexes withPitches:(NSArray *)values;
- (void)addPitchesObject:(FSPPitchEvent *)pitch;
- (void)removePitchesObject:(FSPPitchEvent *)pitch;
- (void)addPitches:(NSOrderedSet *)pitchs;
- (void)removePitches:(NSOrderedSet *)pitchs;
@end
