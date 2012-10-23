//
//  FSPTennisEvent.h
//  FoxSports
//
//  Created by Laura Savino on 1/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPEvent.h"
#import "FSPTournamentEvent.h"
#import "FSPTennisTournamentRound.h"

@interface FSPTennisEvent : FSPEvent <FSPTournamentEvent>

@property (nonatomic, retain) NSString * eventSubtitle;
@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSString * locationName;

@property (nonatomic, retain) NSSet * rounds;

- (void)populateWithTournamentData:(NSArray *)tournamentData;
@end


@interface FSPTennisEvent (CoreDataGeneratedAccessors)

- (void)addRoundsObject:(FSPTennisTournamentRound *)record;
- (void)removeRoundsObject:(FSPTennisTournamentRound *)record;
- (void)addRounds:(NSSet *)records;
- (void)removeRounds:(NSSet *)records;

@end
