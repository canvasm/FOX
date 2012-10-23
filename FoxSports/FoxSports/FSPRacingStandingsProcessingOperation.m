//
//  FSPRacingStandingsProcessingOperation.m
//  FoxSports
//
//  Created by greay on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPRacingStandingsProcessingOperation.h"
#import "FSPStandingsValidator.h"
#import "FSPCoreDataManager.h"
#import "FSPRacingPlayer.h"
#import "NSDictionary+FSPExtensions.h"

@interface FSPStandingsProcessingOperation ()
@property (nonatomic, strong) NSString *branch;
- (NSArray *)existingPlayersInArray:(NSArray *)playerIDs;
@end

@implementation FSPRacingStandingsProcessingOperation
@synthesize branch;

- (id)initWithStandings:(NSArray *)standings branch:(NSString *)aBranch context:(NSManagedObjectContext *)context
{
	self = [super initWithStandings:standings context:context];
	if (self) {
		self.branch = aBranch;
	}
	return self;
	
}

- (void)main;
{
    if (self.isCancelled)
        return;
    
    if (self.standings) {
        [self.managedObjectContext performBlockAndWait:^{
            NSArray *playerIDs = [self.standings valueForKeyPath:@"attributes.nativeId"];
            NSArray *existingPlayers = [self existingPlayersInArray:playerIDs];
            NSArray *existingPlayerKeys = [existingPlayers valueForKeyPath:@"liveEngineID"];
            NSDictionary *existingPlayersDictionary = [NSDictionary dictionaryWithObjects:existingPlayers forKeys:existingPlayerKeys];
            
            // Got all of the teams that already exist so match them up
            for (NSDictionary *playerRecord in self.standings) {
				NSString *playerID = [playerRecord valueForKeyPath:@"attributes.nativeId"];
				FSPRacingPlayer *playerToUpdate = [existingPlayersDictionary objectForKey:playerID];
				
				if (playerToUpdate) {
					[playerToUpdate updateStatsFromDictionary:playerRecord withContext:self.managedObjectContext];
				} else {
					NSArray *playerStats = [playerRecord fsp_objectForKey:@"stats" expectedClass:NSArray.class];
					
					if (playerStats) {
						FSPRacingSeasonStats *seasonStat;
						NSMutableSet * seasons = [NSMutableSet set];
						
						NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"FSPRacingSeasonStats"];
						fetch.predicate = [NSPredicate predicateWithFormat:@"playerID == %@", playerID];
						
						NSError *err;
						NSArray *results = [self.managedObjectContext executeFetchRequest:fetch error:&err];
						if (!err && results.count) {
							seasonStat = [results lastObject];
						} else {
							seasonStat = nil;
						}
						
						if (!seasonStat)
							seasonStat = [NSEntityDescription insertNewObjectForEntityForName:@"FSPRacingSeasonStats"
                                                                       inManagedObjectContext:self.managedObjectContext];
						
						[seasonStat populateWithStandingsArray:playerStats];
						seasonStat.racerName = [playerRecord valueForKeyPath:@"attributes.name"];
						seasonStat.playerID = playerID;
						seasonStat.branch = branch;
						
						[seasons addObject:seasonStat];
					}
				}
                if (self.isCancelled)
                    return;
            }
        }];
    }
}

- (NSArray *)existingPlayersInArray:(NSArray *)playerIDs
{
    NSArray *existingPlayers;
    if (playerIDs == nil) {
        existingPlayers = @[];
    } else {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPRacingPlayer"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"liveEngineID IN %@", playerIDs];
		
        existingPlayers = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    }
    
    return existingPlayers;
}


@end
