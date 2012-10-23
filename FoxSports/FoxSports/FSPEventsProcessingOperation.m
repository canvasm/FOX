//
//  FSPEventProcessingOperation.m
//  FoxSports
//
//  Created by Jason Whitford on 3/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPEventsProcessingOperation.h"
#import "FSPEvent.h"
#import "FSPTeam.h"
#import "FSPGame.h"
#import "FSPEventValidator.h"
#import "FSPCoreDataManager.h"
#import "FSPOrganization.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPManagedObjectCache.h"

@interface FSPEventsProcessingOperation ()
@property (nonatomic, copy) NSArray *events;
@property (assign) BOOL batch;
@property (nonatomic, strong) FSPManagedObjectCache *eventCache;
@property (nonatomic, strong) NSMutableDictionary *batchCache;
@property NSArray *organizationIds;
@end

@implementation FSPEventsProcessingOperation
@synthesize events=_events;
@synthesize batch = _batch;
@synthesize batchCache = _batchCache;

- (id)initWithEvents:(NSArray *)events batch:(BOOL)batch organizationIds:(NSArray *)organizationIds context:(NSManagedObjectContext *)context;
{
    if (self = [super initWithContext:context]) {
        self.events = events;
		self.batch = batch;
        self.organizationIds = organizationIds;
        self.eventCache = [FSPManagedObjectCache cacheForEntityName:NSStringFromClass(FSPEvent.class)
                                                          inContext:self.managedObjectContext];
    }
    return self;
}

- (NSArray *)allOrganizationsForBranch:(NSString *)branch inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPOrganization"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"branch == %@ AND (type != %@) AND (parents.@count == 0)", branch, @"TEAM"];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesSubentities = NO;
    
    NSError *err;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&err];
    if (!err) {
        return results;
    } else {
        NSLog(@"error setting organizations for %@:%@", self, err);
        return nil;
    }
}

- (void)processEvents:(NSArray *)events context:(NSManagedObjectContext *)context outEventIds:(NSMutableSet *)outEventIds outBranch:(NSString **)outBranch;
{
	if (events && [events count] > 0) {
        
        NSArray *eventIds = [events valueForKeyPath:FSPEventUniqueIdKey];
        [outEventIds addObjectsFromArray:eventIds];

        NSMutableSet *associatedOrganizations = NSMutableSet.new;
        for (id orgId in self.organizationIds) {
            id organization = [context objectWithID:orgId];
            [associatedOrganizations addObject:organization];
        }
        
        
        FSPManagedObjectCache *teamsCache = [FSPManagedObjectCache cacheForEntityName:NSStringFromClass(FSPTeam.class)
                                                                            inContext:context];
        
        FSPEventValidator *validator = [[FSPEventValidator alloc] init];
        NSString *thisBranch = nil;
        for (NSDictionary *updatedEvent in events) {
            NSDictionary *validatedDict = [validator validateDictionary:updatedEvent error:nil];
            if (validatedDict) {
                NSString *updatedEventKey = [validatedDict objectForKey:FSPEventUniqueIdKey];
                if (thisBranch) {
                    // Here, we assume we're only processing events for one branch. If not, stuff will break -- see e.g. removeOldActive
                    NSParameterAssert([thisBranch isEqualToString:[validatedDict objectForKey:FSPEventBranchKey]]);
                } else {
                    thisBranch = [validatedDict objectForKey:FSPEventBranchKey];
                }
                FSPEvent *eventToUpdate = (FSPEvent *)[self.eventCache lookupObjectByIdentifier:updatedEventKey];
                
                if (!eventToUpdate && self.batch) {
                    eventToUpdate = [self.batchCache objectForKey:updatedEventKey];
                }
                
                if (!eventToUpdate) {
                    eventToUpdate = [NSEntityDescription insertNewObjectForEntityForName:[FSPEvent entityNameForBranchType:[validatedDict objectForKey:FSPEventBranchKey]]
                                                                  inManagedObjectContext:context];
                    
#if DEBUG_xmas_event_creation
                    if ([validatedDict objectForKey:@"visitingTeamId"] && [validatedDict objectForKey:@"homeTeamId"]) {

                        NSString *vid = [validatedDict valueForKey:@"visitingTeamId"];
                        NSString *hid = [validatedDict valueForKey:@"homeTeamId"];
                        FSPTeam *homeTeam = (FSPTeam *)[teamsCache lookupObjectByIdentifier:hid];
                        FSPTeam *awayTeam = (FSPTeam *)[teamsCache lookupObjectByIdentifier:vid];

                        NSLog(@"creating new event for %@ (%@) vs %@ (%@) on %@", [awayTeam longNameDisplayString],
                              [validatedDict valueForKey:@"visitingTeamScore"],
                              [homeTeam longNameDisplayString],
                              [validatedDict valueForKey:@"homeTeamScore"],
                              [validatedDict valueForKey:@"startDate"]);
                                            
                    }
                    
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FSPEvent"];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@", updatedEventKey];
                    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"uniqueIdentifier" ascending:YES]]];
                    NSFetchedResultsController *fetch = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
                    NSError *error = nil;
                    [fetch performFetch:&error];
                    NSLog(@"non cached call has these events for: %@ \n %@", updatedEventKey, [fetch fetchedObjects]);
#endif

                    
                    if (self.batch) {
                        [self.batchCache setObject:eventToUpdate forKey:updatedEventKey];
                    }
                }
                
                [eventToUpdate populateWithDictionary:validatedDict];

                NSMutableSet *associatedOrganizations = [NSMutableSet setWithSet:[eventToUpdate organizations]];
                if ([validatedDict objectForKey:@"visitingTeamId"] && [validatedDict objectForKey:@"homeTeamId"]) {
                    FSPGame *game = (FSPGame *)eventToUpdate;
                    if (!game.awayTeam) {
                        game.awayTeam = (FSPTeam *)[teamsCache lookupObjectByIdentifier:game.awayTeamIdentifier];
                    }
                    if (!game.homeTeam) {
                        game.homeTeam = (FSPTeam *)[teamsCache lookupObjectByIdentifier:game.homeTeamIdentifier];
                    }
                    if (game.homeTeam) {
                        [associatedOrganizations addObject:game.homeTeam];
                        [associatedOrganizations addObjectsFromArray:[[game.homeTeam allParents] allObjects]];
                    }
                    if (game.awayTeam) {
                        [associatedOrganizations addObject:game.awayTeam];
                        [associatedOrganizations addObjectsFromArray:[[game.awayTeam allParents] allObjects]];
                    }
                }

                NSArray *branchOrgs = [self allOrganizationsForBranch:[validatedDict valueForKey:@"branch"] inContext:context];
                [associatedOrganizations addObjectsFromArray:branchOrgs];
                for (FSPOrganization *org in branchOrgs) {
                    [associatedOrganizations addObjectsFromArray:[[org allParents] allObjects]];
                }
                    
                eventToUpdate.organizations = associatedOrganizations;
            }
            
            if (outBranch) {
                *outBranch = thisBranch;
            }
            
            if (self.isCancelled)
                return;
        }
	}
}

- (void)main
{
    if (self.isCancelled)
        return;
    
    [self.managedObjectContext performBlockAndWait:^{
        //make it a batch if it responds to the chips key
        if ([[[self.events lastObject] fsp_objectForKey:@"chips" defaultValue:@[]] count])
            self.batch = YES;
        
        NSString *thisBranch = nil;
        NSMutableSet *eventIds = NSMutableSet.new;
        if (self.batch) {
            // When batch processing events, keep track of events already processed.
            // On processing of the first batch, the event cache fetch will not return any events that have not been fetched before.
            // These events will get inserted into the context.
            // On processing of next batch, the events just inserted will not be found in the evebnt cache, since another fetch has not been done.
            // Thus, if there are duplicate events in the next batch, they will be inserted in the context again.
            // By keeping track of the events already processed, they can be prevented from being reinserted into the context.

            self.batchCache = [NSMutableDictionary dictionary];
            for (NSDictionary *events in self.events) {
            
                [self processEvents:[events fsp_objectForKey:@"chips" expectedClass:NSArray.class]
                            context:self.managedObjectContext
                        outEventIds:eventIds
                          outBranch:&thisBranch];
            }
        } else {
            [self processEvents:self.events context:self.managedObjectContext outEventIds:eventIds outBranch:&thisBranch];
        }
        
		if (thisBranch) {
            [self removeOldActive:eventIds inBranch:thisBranch fromContext:self.managedObjectContext];
        }
    }];
}

- (void)removeOldActive:(NSSet *)currentEventIDs inBranch:(NSString*)branch fromContext:(NSManagedObjectContext *)context
{
    //remove old events
    NSParameterAssert(branch);
    NSFetchRequest *fetchRequestRemoveActive = [NSFetchRequest fetchRequestWithEntityName:@"FSPEvent"];
    fetchRequestRemoveActive.predicate = [NSPredicate predicateWithFormat:@"branch == %@ AND NOT uniqueIdentifier IN %@", branch, currentEventIDs];
    NSArray *oldChips = [context executeFetchRequest:fetchRequestRemoveActive error:nil];
    for (FSPEvent *oldEvent in oldChips) {
        [context deleteObject:oldEvent];
    }
}

@end
