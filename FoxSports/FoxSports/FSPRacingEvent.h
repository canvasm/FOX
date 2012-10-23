//
//  FSPRacingEvent.h
//  FoxSports
//
//  Created by Laura Savino on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPEvent.h"
#import "FSPTournamentEvent.h"
#import "FSPRacingPlayer.h"
#import "FSPRacingTrackRecords.h"

@interface FSPRacingEvent : FSPEvent <FSPTournamentEvent>

@property (nonatomic, retain) NSString *eventTitle;
@property (nonatomic, retain) NSString *venueName;
@property (nonatomic, retain) NSString *raceType;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *length;

@property (nonatomic, retain) NSString * trackType;

@property (nonatomic, retain) NSNumber * totalLaps;

@property (nonatomic, retain) NSSet * racers;
@property (nonatomic, retain) NSString * trackPhotoURL;
@property (nonatomic, retain) NSSet * trackRecords;

- (void)populateWithPreRaceDictionary:(NSDictionary *)preRace;

@end

@interface FSPRacingEvent (CoreDataGeneratedAccessors)

- (void)addRacersObject:(FSPRacingPlayer *)racer;
- (void)removeRacersObject:(FSPRacingPlayer *)racer;
- (void)addRacers:(NSSet *)racers;
- (void)removeRacers:(NSSet *)racers;

- (void)addTrackRecordsObject:(FSPRacingTrackRecords *)record;
- (void)removeTrackRecordsObject:(FSPRacingTrackRecords *)record;
- (void)addTrackRecords:(NSSet *)records;
- (void)removeTrackRecords:(NSSet *)records;

@end
