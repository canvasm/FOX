//
//  FSPGolfer.m
//  FoxSports
//
//  Created by Jason Whitford on 3/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGolfer.h"
#import "FSPGolfStats.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPGolfer

@dynamic avgDriveDistance;
@dynamic drivingAccuracy;
@dynamic greensInRegulation;
@dynamic isTied;
@dynamic place;
@dynamic putsPerRound;
@dynamic sandSaves;
@dynamic statusKey;
@dynamic thruHole;
@dynamic todayScore;
@dynamic totalScore;
@dynamic totalStrokes;
@dynamic golfEvent;
@dynamic rounds;
@dynamic seasons;

- (void)updateStatsFromDictionary:(NSDictionary *)stats withContext:(NSManagedObjectContext *)context
{
    self.statusKey = [stats fsp_objectForKey:@"ST" defaultValue:@-1];
    self.place = [stats fsp_objectForKey:@"PL" defaultValue:@-1];
    self.isTied = [stats fsp_objectForKey:@"PLT" defaultValue:@(NO)];
    self.totalScore = [stats fsp_objectForKey:@"TS" defaultValue:@-1];
    self.thruHole = [stats fsp_objectForKey:@"TRH" defaultValue:@-1];
    self.todayScore = [stats fsp_objectForKey:@"TDS" defaultValue:@-1];
    self.avgDriveDistance = [stats fsp_objectForKey:@"ADD" defaultValue:@-1];
    self.drivingAccuracy = [stats fsp_objectForKey:@"DA" defaultValue:@-1];
    self.greensInRegulation = [stats fsp_objectForKey:@"GIR" defaultValue:@-1];
    self.sandSaves = [stats fsp_objectForKey:@"SS" defaultValue:@-1];
    self.putsPerRound = [stats fsp_objectForKey:@"PPR" defaultValue:@-1];
    self.totalStrokes = [stats fsp_objectForKey:@"STR" defaultValue:@-1];
    
    //Round Data
    NSInteger currentRound = 1;
    NSArray *rounds = [stats objectForKey:@"RDS"];
    for (NSDictionary *roundStats in rounds) {
        BOOL newRound = NO;
        FSPGolfRound *roundToUpdate;
        if ([self.rounds count]) {
            for (FSPGolfRound *existingRound in self.rounds)
                if (existingRound.round.integerValue == currentRound)
                    roundToUpdate = existingRound;
        }
        
        if (!roundToUpdate) {
            roundToUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"FSPGolfRound" inManagedObjectContext:context];
            newRound = YES;
            roundToUpdate.round = [NSNumber numberWithInt:currentRound];
        }
        
        roundToUpdate.strokes = [roundStats fsp_objectForKey:@"STR" defaultValue:@-1];
        NSArray *holes = [roundStats objectForKey:@"HA"];
        for (NSDictionary *holeStats in holes) {
            NSString *holeLabel = [holeStats fsp_objectForKey:@"LBL" defaultValue:@""];
            FSPGolfHole *holeToUpdate;
            if (!newRound) {
                for (FSPGolfHole *existingHole in roundToUpdate.holes)
                    if ([existingHole.label isEqualToString:holeLabel])
                        holeToUpdate = existingHole;
            }
            
            if (!holeToUpdate)
                holeToUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"FSPGolfHole" inManagedObjectContext:context];
            
            holeToUpdate.label = holeLabel;
            holeToUpdate.par = [holeStats fsp_objectForKey:@"PAR" defaultValue:@-1];
            holeToUpdate.strokes = [holeStats fsp_objectForKey:@"STR" defaultValue:@-1];
            [roundToUpdate addHolesObject:holeToUpdate];
        }
        [self addRoundsObject:roundToUpdate];
        currentRound++;
    }
}

- (void)updateStandingsFromDictionary:(NSDictionary *)stats
{
	NSArray *eventStats = [stats fsp_objectForKey:@"EVT" expectedClass:NSArray.class];
	NSArray *seasonStats = [stats fsp_objectForKey:@"SS" expectedClass:NSArray.class];
	
	if (eventStats) {
		for (NSDictionary *event in eventStats) {
			// ...
		}
	}
	
	if (seasonStats) {
		FSPGolfStats *seasonStat;
		NSMutableSet * seasons = [NSMutableSet set];
		
		NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"FSPGolfStats"];
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
				seasonStat = [NSEntityDescription insertNewObjectForEntityForName:@"FSPGolfStats" inManagedObjectContext:self.managedObjectContext];
			
			[seasonStat populateWithDictionary:season];
			seasonStat.playerID = [self.liveEngineID stringValue];
			
			[seasons addObject:seasonStat];
		}
		self.seasons = [NSSet setWithSet:seasons];
	}
}

- (NSString *)status
{
    NSString *statusString;
    
    switch (self.statusKey.intValue) {
        case 0:
            statusString = @"Pre-Round";
            break;
        case 1:
            statusString = @"In-Progress";
            break;
        case 2:
            statusString = @"WithDrawn";
            break;
        case 3:
            statusString = @"Disqualified";
            break;
        case 4:
            statusString = @"Round Over";
            break;
        case 5:
            statusString = @"Missed Cut";
            break;
        case 6:
            statusString = @"Made Cut/DNF";
            break;
        case 7:
            statusString = @"Final";
            break;
        case 8:
            statusString = @"Pre-Match";
            break;
        case 9:
            statusString = @"In-Progress";
            break;
        case 10:
            statusString = @"Final";
            break;
            
        default:
            statusString = @"";
            break;
    }
    
    return statusString;
}

@end
