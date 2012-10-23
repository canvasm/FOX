//
//  FSPGolfStandingsProcessingOperation.m
//  FoxSports
//
//  Created by greay on 8/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGolfStandingsProcessingOperation.h"
#import "FSPGolfer.h"
#import "FSPGolfStats.h"
#import "FSPStandingsValidator.h"
#import "FSPCoreDataManager.h"
#import "NSDictionary+FSPExtensions.h"

@interface FSPGolfStandingsProcessingOperation ()
@property (nonatomic, strong) NSString *branch;
- (NSArray *)existingPlayersInArray:(NSArray *)playerIDs;
@end


@implementation FSPGolfStandingsProcessingOperation
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
				FSPGolfer *golferToUpdate = [existingPlayersDictionary objectForKey:playerID];
				
				if (golferToUpdate) {
					[golferToUpdate updateStandingsFromDictionary:playerRecord];
				} else {
					NSArray *golferStats = [playerRecord fsp_objectForKey:@"stats" expectedClass:NSArray.class];
					
					if (golferStats) {
						FSPGolfStats *seasonStat;
						NSMutableSet * seasons = [NSMutableSet set];
						
						NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"FSPGolfStats"];
						fetch.predicate = [NSPredicate predicateWithFormat:@"playerID == %@", playerID];
						
						NSError *err;
						NSArray *results = [self.managedObjectContext executeFetchRequest:fetch error:&err];
						if (!err && results.count) {
							seasonStat = [results lastObject];
						} else {
							seasonStat = nil;
						}
						
						if (!seasonStat)
							seasonStat = [NSEntityDescription insertNewObjectForEntityForName:@"FSPGolfStats"
                                                                       inManagedObjectContext:self.managedObjectContext];
						
						[seasonStat populateWithStandingsArray:golferStats];
						seasonStat.playerName = [playerRecord valueForKeyPath:@"attributes.name"];
						seasonStat.playerID = playerID;
						seasonStat.symbolUrl = [playerRecord valueForKeyPath:@"attributes.symbolUrl"];
						seasonStat.branch = branch;
						
						[seasons addObject:seasonStat];
                        [self.managedObjectContext processPendingChanges];
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
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPGolfer"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"liveEngineID IN %@", playerIDs];
		
        existingPlayers = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    }
    
    return existingPlayers;
}

@end
