//
//  FSPGolfer.h
//  FoxSports
//
//  Created by Jason Whitford on 3/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPPlayer.h"
#import "FSPGolfRound.h"

@class FSPPGAEvent;

@interface FSPGolfer : FSPPlayer

@property (nonatomic, retain) NSNumber * avgDriveDistance;
@property (nonatomic, retain) NSNumber * drivingAccuracy;
@property (nonatomic, retain) NSNumber * greensInRegulation;
@property (nonatomic, retain) NSNumber * isTied;
@property (nonatomic, retain) NSNumber * place;
@property (nonatomic, retain) NSNumber * putsPerRound;
@property (nonatomic, retain) NSNumber * sandSaves;
@property (nonatomic, retain) NSNumber * statusKey;
@property (nonatomic, retain) NSNumber * thruHole;
@property (nonatomic, retain) NSNumber * todayScore;
@property (nonatomic, retain) NSNumber * totalScore;
@property (nonatomic, retain) NSNumber * totalStrokes;

@property (nonatomic, retain) FSPPGAEvent * golfEvent;

@property (nonatomic, retain) NSSet * seasons;
@property (nonatomic, retain) NSSet * rounds;

- (void)updateStandingsFromDictionary:(NSDictionary *)stats;

- (NSString *)status;

@end

@interface FSPGolfer (CoreDataGeneratedAccessors)

- (void)addRoundsObject:(FSPGolfRound *)round;
- (void)removeRoundsObject:(FSPGolfRound *)round;
- (void)addRounds:(NSSet *)rounds;
- (void)removeRounds:(NSSet *)rounds;

@end
