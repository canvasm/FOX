//
//  FSPRankingsProcessingOperation.m
//  FoxSports
//
//  Created by Joshua Dubey on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPRankingsProcessingOperation.h"

#import "FSPTeam.h"
#import "FSPTeamRanking.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPRankingsProcessingOperation

static NSString * const FSPTeamRankingsAPPollType = @"AP";
static NSString * const FSPTeamRankingsUSATodayPollType = @"USA";

- (id)initWithRankings:(NSDictionary *)rankings orgId:(NSManagedObjectID *)orgId context:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
        self.rankings = rankings;
        self.orgId = orgId;
    }
    return self;
}

- (void)main;
{
    if (self.isCancelled)
        return;
    
    if (self.rankings) {
        [self.managedObjectContext performBlockAndWait:^{

            NSArray *polls = [self.rankings objectForKey:@"polls"];
            for (NSDictionary *poll in polls) {
                    NSArray *rankedTeams = [poll objectForKey:FSPTeamRankingRankedTeamsKey];
                    NSArray *allTeams = [rankedTeams arrayByAddingObjectsFromArray:[poll objectForKey:@"otherTeams"]];

                NSArray *rankedTeamIds = [allTeams valueForKeyPath:FSPTeamOrganizationIdentifierKey];
                NSArray *teamsToRank = [self teamsToRankInArray:rankedTeamIds];
                NSArray *teamsToRankKeys = [teamsToRank valueForKeyPath:@"uniqueIdentifier"];
                NSDictionary *teamsToRankDictionary = [NSDictionary dictionaryWithObjects:teamsToRank forKeys:teamsToRankKeys];
                
                for (NSDictionary *rankingsDictionary in rankedTeams) {
                    NSString *teamId = [rankingsDictionary objectForKey:FSPTeamOrganizationIdentifierKey];
                    FSPTeam *teamToUpdate = [teamsToRankDictionary objectForKey:teamId];
                    
                    if (teamToUpdate) {
                        NSMutableDictionary *teamRankingDictionary = [rankingsDictionary mutableCopy];
                        [teamRankingDictionary setObject:[poll objectForKey:FSPTeamRankingPollTypeKey] forKey:FSPTeamRankingPollTypeKey];
                        [teamToUpdate updateTeamRankingsWithDictionary:teamRankingDictionary primaryRankingPoll:[self.rankings objectForKey:@"primaryPoll"]];
                    }
                }
            }
        }];
    }
}

- (NSArray *)teamsToRankInArray:(NSArray *)teamIds;
{
    NSArray *teamsToRank;
    if (teamIds == nil) {
        teamsToRank = @[];
    } else {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTeam"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier IN %@", teamIds];
        
        teamsToRank = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    }
    return teamsToRank;
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

- (void)clearCurrentRankings
{
    FSPOrganization *organization = (FSPOrganization *)[self.managedObjectContext existingObjectWithID:self.orgId error:nil];
    if (!organization)
        return;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPTeam"];
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"pollRanking > 0 AND branch == %@", organization.branch];
    fetchRequest.predicate = fetchPredicate;
    NSArray *rankedTeams = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (FSPTeam *team in rankedTeams) {
//        team.pollRanking = nil;
    }
}

@end
