//
//  FSPUFCEvent.h
//  FoxSports
//
//  Created by Laura Savino on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPEvent.h"
#import "FSPTournamentEvent.h"

@class FSPUFCFight;

@interface FSPUFCEvent : FSPEvent <FSPTournamentEvent>

@property (nonatomic, retain) NSString * eventSubtitle;
@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSSet * fights;

@end

@interface FSPUFCEvent (CoreDataGeneratedAccessors)
- (void)insertObject:(FSPUFCFight *)value inFightsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFightsAtIndex:(NSUInteger)idx;
- (void)insertFights:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFightsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFightsAtIndex:(NSUInteger)idx withObject:(FSPUFCFight *)value;
- (void)replaceFightsAtIndexes:(NSIndexSet *)indexes withFights:(NSArray *)values;
- (void)addFightsObject:(FSPUFCFight *)fight;
- (void)removeFightsObject:(FSPUFCFight *)fight;
- (void)addFights:(NSOrderedSet *)fights;
- (void)removeFights:(NSOrderedSet *)fights;
@end