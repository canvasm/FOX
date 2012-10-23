//
//  FSPUFCMatchupProcessingOperation.m
//  FoxSports
//
//  Created by Matthew Fay on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCMatchupProcessingOperation.h"
#import "FSPCoreDataManager.h"
#import "FSPEvent.h"
#import "FSPUFCEvent.h"
#import "FSPUFCFight.h"
#import "FSPUFCPlayer.h"

@implementation FSPUFCMatchupProcessingOperation {
    NSDictionary *matchupData;
    NSManagedObjectID *eventManagedObjectID;
}

- (id)initWithUFCEventId:(NSManagedObjectID *)eventId matchupData:(NSDictionary *)UFCMatchupData
                 context:(NSManagedObjectContext *)context {
    if (self = [super initWithContext:context])
    {
        matchupData = [UFCMatchupData copy];
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
        
        if (!event || ![event isKindOfClass:[FSPUFCEvent class]])
            return;
        
        if (matchupData) {
            FSPUFCEvent * UFCEvent = (FSPUFCEvent *)event;
            //TODO: for now we are recreating the data every time
            //this is because each fight doesnt have a unique identifier
            UFCEvent.fights = nil;
            
            for (NSDictionary *fight in matchupData) {
                FSPUFCFight *newFight = [NSEntityDescription insertNewObjectForEntityForName:@"FSPUFCFight"
                                                                      inManagedObjectContext:self.managedObjectContext];
                newFight.fighter1 = [NSEntityDescription insertNewObjectForEntityForName:@"FSPUFCPlayer"
                                                                  inManagedObjectContext:self.managedObjectContext];
                newFight.fighter2 = [NSEntityDescription insertNewObjectForEntityForName:@"FSPUFCPlayer"
                                                                  inManagedObjectContext:self.managedObjectContext];
                [newFight populateWithDictionary:fight];
                
                [UFCEvent addFightsObject:newFight];
            }
        }
    }];
}

@end
