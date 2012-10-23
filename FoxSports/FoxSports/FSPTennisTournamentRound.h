//
//  FSPTennisTournamentRound.h
//  FoxSports
//
//  Created by greay on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPTennisMatch.h"

@class FSPTennisEvent;

@interface FSPTennisTournamentRound : NSManagedObject

@property (nonatomic, retain) NSNumber * ordinal;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *matches;
@property (nonatomic, retain) FSPTennisEvent *event;

- (void)populateWithDictionary:(NSDictionary *)dictionary;

@end

@interface FSPTennisTournamentRound (CoreDataGeneratedAccessors)

- (void)addMatchesObject:(FSPTennisMatch *)value;
- (void)removeMatchesObject:(FSPTennisMatch *)value;
- (void)addMatches:(NSSet *)values;
- (void)removeMatches:(NSSet *)values;

@end
