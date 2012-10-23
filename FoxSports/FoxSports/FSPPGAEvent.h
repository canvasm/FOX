//
//  FSPPGAEvent.h
//  FoxSports
//
//  Created by Laura Savino on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPEvent.h"
#import "FSPTournamentEvent.h"
#import "FSPGolfer.h"


@interface FSPPGAEvent : FSPEvent <FSPTournamentEvent>

@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSString * venueName;
@property (nonatomic, retain) NSString * winnerName;
@property (nonatomic, retain) NSNumber * winnerPrizeMoney;
@property (nonatomic, retain) NSNumber * winnerScore;
@property (nonatomic, retain) NSNumber * winnerStrokesUnder;
@property (nonatomic, retain) NSSet * golfers;

- (NSString *)dateGroup;

@end

@interface FSPPGAEvent (CoreDataGeneratedAccessors)

- (void)addGolfersObject:(FSPGolfer *)golfer;
- (void)removeGolfersObject:(FSPGolfer *)golfer;
- (void)addGolfers:(NSSet *)golfers;
- (void)removeGolfers:(NSSet *)golfers;

@end