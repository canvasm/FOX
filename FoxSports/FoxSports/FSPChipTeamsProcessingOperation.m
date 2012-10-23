//
//  FSPChipTeamsProcessingOperation.m
//  FoxSports
//
//  Created by Ed McKenzie on 8/30/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPChipTeamsProcessingOperation.h"
#import "FSPManagedObjectCache.h"
#import "FSPTeam.h"
#import "FSPGame.h"

@interface FSPChipTeamsProcessingOperation ()

@property (nonatomic, strong) FSPManagedObjectCache *teamsCache;

@end

@implementation FSPChipTeamsProcessingOperation

- (id)initWithContext:(NSManagedObjectContext *)context {
    if ((self = [super initWithContext:context])) {
        self.teamsCache = [FSPManagedObjectCache cacheForEntityName:NSStringFromClass(FSPTeam.class)
                                                          inContext:context];
    }
    return self;
}

- (void)main {
    if (self.isCancelled)
        return;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass(FSPGame.class)];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"homeTeam == nil OR awayTeam == nil"];
        NSArray *eventsWithMissingTeams = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (eventsWithMissingTeams) {
            for (FSPEvent *event in eventsWithMissingTeams) {
                if ([event isKindOfClass:FSPGame.class]) {
                    FSPGame *game = (FSPGame *)event;
                    NSMutableSet *associatedOrganizations = [NSMutableSet setWithSet:[game organizations]];
                    if (!game.awayTeam) {
                        game.awayTeam = (FSPTeam *)[self.teamsCache lookupObjectByIdentifier:game.awayTeamIdentifier];
                    }
                    if (!game.homeTeam) {
                        game.homeTeam = (FSPTeam *)[self.teamsCache lookupObjectByIdentifier:game.homeTeamIdentifier];
                    }
                    if (game.homeTeam) {
                        [associatedOrganizations addObject:game.homeTeam];
                        [associatedOrganizations addObjectsFromArray:[[game.homeTeam allParents] allObjects]];
                    }
                    if (game.awayTeam) {
                        [associatedOrganizations addObject:game.awayTeam];
                        [associatedOrganizations addObjectsFromArray:[[game.awayTeam allParents] allObjects]];
                    }
                game.organizations = associatedOrganizations;
            }
        }
    }
     }];
}

@end
