//
//  FSPLiveEngineChipProcessingOperation.m
//  FoxSports
//
//  Created by Matthew Fay on 5/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPLiveEngineChipProcessingOperation.h"
#import "FSPCoreDataManager.h"
#import "FSPEvent.h"
#import "FSPGame.h"
#import "FSPLiveEngineEventValidator.h"

@interface FSPLiveEngineChipProcessingOperation ()
@property (nonatomic, copy) NSArray * events;
@end

@implementation FSPLiveEngineChipProcessingOperation

@synthesize events = _events;

- (id)initWithEvents:(NSArray *)events context:(NSManagedObjectContext *)context {
    if (self = [super initWithContext:context]) {
        self.events = events;
    }
    return self;
}

- (void)main
{
    if (self.isCancelled)
        return;
    
    [self.managedObjectContext performBlockAndWait:^{
        if (self.events && [self.events count] > 0) {
            
            NSArray *eventIds = [self.events valueForKeyPath:@"GID"];
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPEvent"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"liveEngineIdentifier IN %@", eventIds];
            
            NSArray *existingEvents = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
            NSArray *existingEventsKeys = [existingEvents valueForKeyPath:@"liveEngineIdentifier"];
            NSDictionary *existingEventsDictionary = [NSDictionary dictionaryWithObjects:existingEvents forKeys:existingEventsKeys];
            
            FSPLiveEngineEventValidator *validator = [[FSPLiveEngineEventValidator alloc] init];
            FSPEvent *eventToUpdate;
            for (NSDictionary *updatedEvent in self.events) {
                NSDictionary *validatedDict = [validator validateDictionary:updatedEvent error:nil];
                if (validatedDict) {
                    NSString *updatedEventKey = [validatedDict objectForKey:@"GID"];
                    eventToUpdate = [existingEventsDictionary objectForKey:updatedEventKey];
                    
                    if (eventToUpdate && [eventToUpdate isKindOfClass:[FSPGame class]] && eventToUpdate.eventStarted.boolValue && !eventToUpdate.eventCompleted.boolValue) {
                        if (![eventToUpdate.uniqueIdentifier isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@/%@", FSPSelectedEventUserDefaultsPrefixKey, [eventToUpdate getTopLevelOrganization].uniqueIdentifier]]])
                            [eventToUpdate populateWithLeagueGameBundleDictionary:validatedDict];
                    }
                }
                
                if (self.isCancelled)
                    return;
            }
        }
    }];
}

@end
