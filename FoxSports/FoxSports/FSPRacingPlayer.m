//
//  FSPRacingPlayer.m
//  FoxSports
//
//  Created by Matthew Fay on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPRacingPlayer.h"
#import "FSPRacingEvent.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPCoreDataManager.h"
#import "FSPRacingSeasonStats.h"


@implementation FSPRacingPlayer
@dynamic playerNumber;
@dynamic raceStartPosition;
@dynamic vehicleDescription;

@dynamic qualifyingSpeed;
@dynamic qualifyingTime;
@dynamic positionInRace;
@dynamic positionInClass;
@dynamic topSpeed;
@dynamic intervalBehindLeader;
@dynamic intervalBehindLeaderType;
@dynamic time;
@dynamic bestLapTime;
@dynamic laps;
@dynamic points;
@dynamic bonus;
@dynamic status;
@dynamic winnings;

@dynamic seasons;
@dynamic race;

- (void)updateStatsFromDictionary:(NSDictionary *)stats withContext:(NSManagedObjectContext *)context
{
        NSArray *eventStats = [stats fsp_objectForKey:@"EVT" expectedClass:NSArray.class];
        NSArray *seasonStats = [stats fsp_objectForKey:@"SS" expectedClass:NSArray.class];
        
        if (eventStats) {
            for (NSDictionary *event in eventStats) {
                [self populateWithEventStats:event];
            }
        }
        
        if (seasonStats) {
            FSPRacingSeasonStats *seasonStat;
            NSMutableSet * seasons = [NSMutableSet set];
            
			NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"FSPRacingSeasonStats"];
            for (NSDictionary *season in seasonStats) {
				fetch.predicate = [NSPredicate predicateWithFormat:@"playerID == %@", self.liveEngineID];
				
				NSError *err;
				NSArray *results = [self.managedObjectContext executeFetchRequest:fetch error:&err];
				if (!err && results.count) {
					seasonStat = [results lastObject];
				} else {
					seasonStat = nil;
				}

                if (!seasonStat)
                    seasonStat = [NSEntityDescription insertNewObjectForEntityForName:@"FSPRacingSeasonStats" inManagedObjectContext:self.managedObjectContext];
                
                [seasonStat populateWithDictionary:season];
				seasonStat.playerID = [self.liveEngineID stringValue];
				
                [seasons addObject:seasonStat];
            }
            self.seasons = [NSSet setWithSet:seasons];
        }
}

- (void)populateWithEventStats:(NSDictionary *)stats
{
     NSNumber *noValue = @-1;
    if ([[stats objectForKey:@"SN"] isEqualToString:@"Qualifying Speeds"]) {
        self.qualifyingSpeed = [stats fsp_objectForKey:@"SP" defaultValue:noValue];
        self.qualifyingTime = [stats fsp_objectForKey:@"TIME" defaultValue:@"--"];
    } else {
        self.positionInClass = [stats fsp_objectForKey:@"PIC" defaultValue:noValue];
        self.positionInRace = [stats fsp_objectForKey:@"POS" defaultValue:noValue];
        self.topSpeed = [stats fsp_objectForKey:@"SP" defaultValue:noValue];
        self.intervalBehindLeader = [stats fsp_objectForKey:@"INT" defaultValue:@"--"];
        self.intervalBehindLeaderType = [stats fsp_objectForKey:@"INTT" defaultValue:@"--"];
        self.time = [stats fsp_objectForKey:@"TIME" defaultValue:@"--"];
        self.bestLapTime = [stats fsp_objectForKey:@"BL" defaultValue:@"--"];
        self.laps = [stats fsp_objectForKey:@"LP" defaultValue:noValue];
        self.points = [stats fsp_objectForKey:@"PT" defaultValue:noValue];
        self.bonus = [stats fsp_objectForKey:@"BN" defaultValue:noValue];
        self.status = [stats fsp_objectForKey:@"ST" defaultValue:@"--"];
        self.winnings = [stats fsp_objectForKey:@"WIN" defaultValue:noValue];
    }
}

- (NSString *)winningsInCurrencyFormat
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString *formattedWinnings = [numberFormatter stringFromNumber:self.winnings];
    NSArray *formattedWinningsComponents = [formattedWinnings componentsSeparatedByString:@"."];
    return [formattedWinningsComponents objectAtIndex:0];
}

@end
