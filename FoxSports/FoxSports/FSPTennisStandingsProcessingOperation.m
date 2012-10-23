//
//  FSPTennisStandingsProcessingOperation.m
//  FoxSports
//
//  Created by Matthew Fay on 8/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisStandingsProcessingOperation.h"
#import "FSPTennisPlayer.h"
#import "FSPTennisSeasonStats.h"
#import "NSDictionary+FSPExtensions.h"

@interface FSPTennisStandingsProcessingOperation ()
@property (nonatomic, strong) NSString *branch;
- (NSArray *)existingPlayersInArray:(NSArray *)playerIDs;
@end

@implementation FSPTennisStandingsProcessingOperation
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
				FSPTennisPlayer *playerToUpdate = [existingPlayersDictionary objectForKey:playerID];
				
				if (playerToUpdate) {
					[playerToUpdate updateStatsFromDictionary:playerRecord withContext:self.managedObjectContext];
				} else {
					NSArray *playerStats = [playerRecord fsp_objectForKey:@"stats" expectedClass:NSArray.class];
					
					if (playerStats) {
						FSPTennisSeasonStats *seasonStat;
						NSMutableSet * seasons = [NSMutableSet set];
						
						NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"FSPTennisSeasonStats"];
						fetch.predicate = [NSPredicate predicateWithFormat:@"playerID == %@", playerID];
						
						NSError *err;
						NSArray *results = [self.managedObjectContext executeFetchRequest:fetch error:&err];
						if (!err && results.count) {
							seasonStat = [results lastObject];
						} else {
							seasonStat = nil;
						}
						
						if (!seasonStat)
							seasonStat = [NSEntityDescription insertNewObjectForEntityForName:@"FSPTennisSeasonStats"
                                                                       inManagedObjectContext:self.managedObjectContext];
						
						[seasonStat populateWithStandingsArray:playerStats];
						seasonStat.playerName = [playerRecord valueForKeyPath:@"attributes.name"];
						seasonStat.playerID = playerID;
						seasonStat.branch = self.branch;
                        seasonStat.flagURL = [playerRecord valueForKeyPath:@"attributes.symbolUrl"];
						
						[seasons addObject:seasonStat];
					}
				}
                if (self.isCancelled)
                    return;
            }
            
            if (!self.isCancelled) {
                NSError *error;
                if (![self.managedObjectContext save:&error])
                    NSLog(@"failed to save context in FSPStandingsProcessingOperation error: %@", error);
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
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTennisPlayer"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"liveEngineID IN %@", playerIDs];
		
        existingPlayers = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    }
    
    return existingPlayers;
}


@end