//
//  FSPInjuryReportProcessingOperation.m
//  FoxSports
//
//  Created by Matthew Fay on 4/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPInjuryReportProcessingOperation.h"
#import "FSPEvent.h"
#import "FSPPlayerInjury.h"
#import "FSPPlayerInjuryValidator.h"
#import "FSPCoreDataManager.h"

@implementation FSPInjuryReportProcessingOperation {
    NSArray *injuries;
    NSManagedObjectID *eventManagedObjectID;
}

- (id)initWithEventId:(NSManagedObjectID *)eventId injuries:(NSArray *)injuryArray context:(NSManagedObjectContext *)context {
    if (self = [super initWithContext:context])
    {
        injuries = [injuryArray copy];
        eventManagedObjectID = eventId;
    }
    return self;
}

- (void)main
{
    if (self.isCancelled)
        return;
    
    [self.managedObjectContext performBlockAndWait:^{
        FSPEvent *event = (FSPEvent *)[self.managedObjectContext existingObjectWithID:eventManagedObjectID error:nil];
        
        if (!event)
            return;
        
        if (injuries) {
            
            NSFetchRequest *previousInjuries = [NSFetchRequest fetchRequestWithEntityName:@"FSPPlayerInjury"];
            previousInjuries.predicate = [NSPredicate predicateWithFormat:@"eventIdentifier == %@", event.uniqueIdentifier];
            NSArray *allInjuries = [self.managedObjectContext executeFetchRequest:previousInjuries error:nil];
            
            for (FSPPlayerInjury *inj in allInjuries) {
                [self.managedObjectContext deleteObject:inj];
            }
            
            [self.managedObjectContext processPendingChanges];

            FSPPlayerInjuryValidator *injuryValidator = [[FSPPlayerInjuryValidator alloc] init];
            for (NSDictionary *teamInjuries in injuries) {
                if (self.isCancelled) return;
                
                NSArray *playerInjuries = [teamInjuries objectForKey:@"injuries"];
                
                if ([playerInjuries count] > 0 && [teamInjuries objectForKey:FSPPlayerInjuryTeamIdKey]) {
                    
                    for (NSDictionary *playersInjured in playerInjuries) {
                        NSDictionary *validInjuries = [injuryValidator validateDictionary:playersInjured error:nil];
                        
                        if (validInjuries) {
                            FSPPlayerInjury *injury = [NSEntityDescription insertNewObjectForEntityForName:@"FSPPlayerInjury"
                                                                                    inManagedObjectContext:self.managedObjectContext];
                            injury.eventIdentifier = event.uniqueIdentifier;
                            injury.teamIdentifier = [teamInjuries objectForKey:FSPPlayerInjuryTeamIdKey];
                            injury.firstName = [playersInjured objectForKey:FSPPlayerInjuryFirstNameKey];
                            injury.lastName = [playersInjured objectForKey:FSPPlayerInjuryLastNameKey];
                            injury.position = [playersInjured objectForKey:FSPPlayerInjuryPositionKey];
                            injury.injury = [playersInjured objectForKey:FSPPlayerInjuryKey];
                            injury.status = [playersInjured objectForKey:FSPPlayerInjuryStatusKey];
                            injury.imageURL = [playersInjured objectForKey:FSPPlayerInjuryImageURLKey];
                        }
                    }
                }
            }
        }
    }];
}

@end
