//
//  FSPNBAStandingsProcessingOperation.m
//  DataCoordinatorTestApp
//
//  Created by Chase Latta on 3/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPStandingsProcessingOperation.h"
#import "FSPTeam.h"
#import "FSPTeamRecord.h"
#import "FSPStandingsValidator.h"
#import "FSPCoreDataManager.h"
#import "NSNumber+FSPExtensions.h"

@interface FSPStandingsProcessingOperation ()
- (NSArray *)existingTeamsInArray:(NSArray *)teamIds;
@end

@implementation FSPStandingsProcessingOperation
@synthesize standings = _standings;

- (id)initWithStandings:(NSArray *)standings context:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
        self.standings = standings;
    }
    return self;
}

- (void)main;
{
    if (self.isCancelled)
        return;
    
    if (self.standings) {
        [self.managedObjectContext performBlockAndWait:^{
            NSArray *teamIds = [self.standings valueForKeyPath:FSPTeamOrganizationIdentifierKey];
            NSArray *existingTeams = [self existingTeamsInArray:teamIds];
            NSArray *existingTeamsKeys = [existingTeams valueForKeyPath:@"uniqueIdentifier"];
            NSDictionary *existingTeamsDictionary = [NSDictionary dictionaryWithObjects:existingTeams forKeys:existingTeamsKeys];
            
            // Got all of the teams that already exist so match them up
            FSPStandingsValidator *validator = [[FSPStandingsValidator alloc] init];
            for (NSDictionary *teamRecord in self.standings) {
                NSDictionary *validatedDict = [validator validateDictionary:teamRecord error:nil];
                if (validatedDict) {
                    NSString *teamId = [validatedDict objectForKey:FSPTeamOrganizationIdentifierKey];
                    FSPTeam *teamToUpdate = [existingTeamsDictionary objectForKey:teamId];
                    
                    if (teamToUpdate) {
                        [teamToUpdate updateTeamRecordsWithDictionary:validatedDict];
                    }
                }
                if (self.isCancelled)
                    return;
            }
			if ([[existingTeams lastObject] viewType] == FSPNFLViewType) {
				NSComparisonResult (^highToLowComparator)(id obj1, id obj2) = ^NSComparisonResult(id obj1, id obj2) {
					NSNumber *n1 = [NSNumber numberWithFloat:[obj1 floatValue]];
					NSNumber *n2 = [NSNumber numberWithFloat:[obj2 floatValue]];
					return [n2 compare:n1];
				};
				NSComparisonResult (^lowToHighComparator)(id obj1, id obj2) = ^NSComparisonResult(id obj1, id obj2) {
					NSNumber *n1 = [NSNumber numberWithFloat:[obj1 floatValue]];
					NSNumber *n2 = [NSNumber numberWithFloat:[obj2 floatValue]];
					return [n1 compare:n2];
				};
				
				NSInteger rank = 0;

				NSCountedSet *countedYards = [NSCountedSet setWithArray:[existingTeams valueForKey:@"yardsPerGame"]];
				NSArray *distinctYards = [[countedYards allObjects] sortedArrayUsingComparator:highToLowComparator];
				for (FSPTeam *team in existingTeams) {
					NSString *tieString = ([countedYards countForObject:team.yardsPerGame] > 1) ? @"T-" : @"";
					rank = 0;
					for (NSString *value in distinctYards) {
						if ([value isEqualToString:team.yardsPerGame]) {
							rank += 1;
							break;
						} else {
							rank += [countedYards countForObject:value];
						}
					}
					team.yardsPerGameRankingString = [NSString stringWithFormat:@"%@%@", tieString, [[NSNumber numberWithInteger:rank] fsp_ordinalStringValue]];
				}

				NSCountedSet *countedOpponentYards = [NSCountedSet setWithArray:[existingTeams valueForKey:@"opponentYardsPerGame"]];
				NSArray *distinctOpponentYards = [[countedOpponentYards allObjects] sortedArrayUsingComparator:lowToHighComparator];
				for (FSPTeam *team in existingTeams) {
					NSString *tieString = ([countedOpponentYards countForObject:team.opponentYardsPerGame] > 1) ? @"T-" : @"";
					rank = 0;
					for (NSString *value in distinctOpponentYards) {
						if ([value isEqualToString:team.opponentYardsPerGame]) {
							rank += 1;
							break;
						} else {
							rank += [countedOpponentYards countForObject:value];
						}
					}
					team.opponentYardsPerGameRankingString = [NSString stringWithFormat:@"%@%@", tieString, [[NSNumber numberWithInteger:rank] fsp_ordinalStringValue]];
				}

				NSCountedSet *countedTurnovers = [NSCountedSet setWithArray:[existingTeams valueForKey:@"turnoversPerGame"]];
				NSArray *distinctTurnovers = [[countedTurnovers allObjects] sortedArrayUsingComparator:lowToHighComparator];
				for (FSPTeam *team in existingTeams) {
					NSString *tieString = ([countedTurnovers countForObject:team.turnoversPerGame] > 1) ? @"T-" : @"";
					rank = 0;
					for (NSString *value in distinctTurnovers) {
						if ([value isEqualToString:team.turnoversPerGame]) {
							rank += 1;
							break;
						} else {
							rank += [countedTurnovers countForObject:value];
						}
					}
					team.turnoversPerGameRankingString = [NSString stringWithFormat:@"%@%@", tieString, [[NSNumber numberWithInteger:rank] fsp_ordinalStringValue]];
				}

				NSArray *sortedTeams = [existingTeams sortedArrayUsingComparator:^NSComparisonResult(FSPTeam *obj1, FSPTeam *obj2) {
					NSComparisonResult result = [obj2.overallRecord.wins compare:obj1.overallRecord.wins];
					if (result == NSOrderedSame) {
						result = [obj1.overallRecord.losses compare:obj2.overallRecord.losses];
					}
					return result;
				}];
				
				FSPTeam *currentTeam = nil;
				FSPTeam *lastTeam = nil;
				NSString *tieString;
				BOOL tie = NO;
				rank = 0;
				for (NSUInteger i = 0; i < sortedTeams.count; i++) {
					currentTeam = [sortedTeams objectAtIndex:i];
					
					tie = [currentTeam.overallRecord.winLossRecordString isEqual:lastTeam.overallRecord.winLossRecordString];
					if (!tie) {
						rank = i + 1;
					}
					tieString = (tie) ? @"T-" : @"";
					currentTeam.winsRankingString = [NSString stringWithFormat:@"%@%@", tieString, [[NSNumber numberWithInteger:rank] fsp_ordinalStringValue]];
					// since we don't know if the 1st team in a rank is a tie, go back & fix it here
					if (tie) {
						lastTeam.winsRankingString = currentTeam.winsRankingString;
					}
					
					lastTeam = currentTeam;
				}
//				NSArray *ranks = [sortedTeams valueForKey:@"winsRankingString"];
//				NSArray *wl = [sortedTeams valueForKeyPath:@"overallRecord.winLossRecordString"];
//				NSLog(@"%@\n%@", wl, ranks);
			}
        }];
    }
}

- (NSArray *)existingTeamsInArray:(NSArray *)teamIds;
{
    NSArray *existingTeams;
    if (teamIds == nil) {
        existingTeams = @[];
    } else {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTeam"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier IN %@", teamIds];
    
        existingTeams = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    }
    
    return existingTeams;
}


@end
