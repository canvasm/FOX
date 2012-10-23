//
//  FSPGame.m
//  FoxSports
//
//  Created by Laura Savino on 2/4/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGame.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPTeam.h"
#import "FSPCoreDataManager.h"
#import "FSPAppDelegate.h"

@implementation FSPGame

@dynamic winningTeamIdentifier;
@dynamic homeTeamIdentifier;
@dynamic homeTeamScore;
@dynamic awayTeamIdentifier;
@dynamic awayTeamScore;
@dynamic awayTeam;
@dynamic homeTeam;
@dynamic periods;
@dynamic odds;
@dynamic homeTeamLiveEngineID;
@dynamic awayTeamLiveEngineID;
@dynamic homeTeamPlayers;
@dynamic awayTeamPlayers;
@dynamic playByPlayItems;
@dynamic homeTimeoutsRemaining;
@dynamic awayTimeoutsRemaining;

- (NSUInteger)maxTimeouts;
{
    return 0;
}

- (void)populateWithDictionary:(NSDictionary *)eventData;
{
    [super populateWithDictionary:eventData];
    
    self.homeTeamIdentifier = [eventData fsp_objectForKey:@"homeTeamId" defaultValue:@""];
    self.awayTeamIdentifier = [eventData fsp_objectForKey:@"visitingTeamId" defaultValue:@""];

#ifdef DEBUG_xmas_chips
    NSLog(@"home team ID: %@ away team ID: %@", self.homeTeamIdentifier, self.awayTeamIdentifier);
    
    NSLog(@"home team: %@", self.homeTeam.name);
    NSLog(@"away team: %@", self.awayTeam.name);

#endif
    
    //Winning team identifier is not sent through the feed, but calculated and stored on the object
    if (self.eventCompleted.boolValue) {
        self.awayTeamScore = @([[eventData fsp_objectForKey:@"visitingTeamScore" defaultValue:@"0"] integerValue]);
        self.homeTeamScore = @([[eventData fsp_objectForKey:@"homeTeamScore" defaultValue:@"0"] integerValue]);
        
        NSComparisonResult teamScoreComparisonResult = [self.homeTeamScore compare:self.awayTeamScore];
        if(teamScoreComparisonResult == NSOrderedAscending)
            self.winningTeamIdentifier = self.awayTeamIdentifier;
        else if(teamScoreComparisonResult == NSOrderedDescending)
            self.winningTeamIdentifier = self.homeTeamIdentifier;
    }
	
	NSSet *orgs = self.organizations;
	if (!orgs) {
		orgs = [NSSet set];
	}
	self.organizations = [orgs setByAddingObjectsFromSet:[NSSet setWithObjects:self.homeTeam, self.awayTeam, nil]];
}

- (void)populateWithLeagueGameBundleDictionary:(NSDictionary *)eventData
{
    [super populateWithLeagueGameBundleDictionary:eventData];
    if ([eventData objectForKey:@"A"] && [eventData objectForKey:@"H"]) {
        self.awayTeamScore = [[eventData objectForKey:@"A"] objectForKey:@"TS"];
        self.homeTeamScore = [[eventData objectForKey:@"H"] objectForKey:@"TS"];
    }
}

- (BOOL)matchupAvailable
{
    return NO;
}

- (FSPGamePlayByPlayItem *)gameStatePlayByPlayItem
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"FSPGamePlayByPlayItem"];
    NSSortDescriptor *sortDescriptorPeriod = [NSSortDescriptor sortDescriptorWithKey:@"period" ascending:YES];
    NSSortDescriptor *sortDescriptorSequence = [NSSortDescriptor sortDescriptorWithKey:@"sequenceNumber" ascending:YES];
    
    fetch.shouldRefreshRefetchedObjects = YES;
    fetch.sortDescriptors = @[sortDescriptorPeriod, sortDescriptorSequence];
    fetch.predicate = [NSPredicate predicateWithFormat:@"game.uniqueIdentifier == %@ AND currentPlayerHome != nil AND currentPlayerAway != nil", self.uniqueIdentifier];
	
	NSArray *objects = [self.managedObjectContext executeFetchRequest:fetch error:nil];
	return [objects lastObject];
}

- (UIColor *)homeTeamColor;
{
    return self.homeTeam.teamColor;
}

- (UIColor *)awayTeamColor;
{
    // TODO: store color so we don't have to compare each time
    if ([self.awayTeam.teamColorNameTag isEqualToString:self.homeTeam.teamColorNameTag]) {
        return self.awayTeam.alternateTeamColor;
    }
    return self.awayTeam.teamColor;
}

@end
