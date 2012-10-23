//
//  FSPDataCoordinator+EventUpdating.m
//  FoxSports
//
//  Created by Chase Latta on 3/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPDataCoordinator+EventUpdating.h"
#import "FSPDataCoordinator_Internal.h"

#import "FSPPollingCenter.h"
#import "FSPLogging.h"
#import "FSPCoreDataManager.h"

#import "FSPGameOddsProcessingOperation.h"
#import "FSPStoryProcessingOperation.h"
#import "FSPGameDictionaryProcessingOperation.h"
#import "FSPMessageBundleProcessingOperation.h"
#import "FSPInjuryReportProcessingOperation.h"
#import "FSPMLBPitchingMatchupProcessingOperation.h"
#import "FSPUFCMatchupProcessingOperation.h"
#import "FSPProcessingOperationQueue.h"
#import "FSPTennisResultsProcessingOperation.h"

#import "FSPPlayerInjuryValidator.h"

#import "FSPEvent.h"
#import "FSPGame.h"
#import "FSPStory.h"
#import "FSPRacingEvent.h"
#import "FSPTennisEvent.h"
#import "FSPPlayerInjury.h"

#import "NSDictionary+FSPExtensions.h"

@interface FSPDataCoordinator (EventUpdating_Private)

- (void)updateOddsForEvent:(NSString *)eventIdentifier;

- (void)beginUpdatingLiveEngineMessageBundlesForEvent:(NSManagedObjectID *)eventId liveEngineEventIdentifier:(NSNumber *)eventIdentifier;

@end


NSString * const FSPDataCoordinatorUpdatedInjuryReportForEventNotification = @"FSPDataCoordinatorUpdatedInjuryReportForEvent";
NSString * const FSPDataCoordinatorFailedToUpdateInjuryReportForEventNotification = @"FSPDataCoordinatorFailedToUpdateInjuryReportForEvent";
NSString * const FSPDataCoordinatorInjuryReportObjectIDKey = @"FSPDataCoordinatorInjuryReportObjectIDKey";

NSString * const FSPDataCoordinatorDidUpdateOddsForEventNotification = @"FSPDataCoordinatorDidUpdateOddsForEventNotification";
NSString * const FSPDataCoordinatorDidUpdatePitchingMatchupForEventNotification = @"FSPDataCoordinatorDidUpdatePitchingMatchupForEventNotification";


@implementation FSPDataCoordinator (EventUpdating)

- (void)beginUpdatingEvent:(NSManagedObjectID *)eventId;
{
    NSManagedObjectContext *context = self.managedObjectContext;
    [context performBlock:^{
        FSPEvent *event = (FSPEvent *)[context existingObjectWithID:eventId error:nil];
        if (!event)
            return;
        
        NSParameterAssert([event isKindOfClass:FSPEvent.class]);
        
        [self updateLiveEngineGameDictionaryForEvent:eventId update:YES];
    }];
}


- (void)updatePitchingMatchupForMLBGame:(NSManagedObjectID *)eventId;
{
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;
    [context performBlock:^{
        FSPEvent *event = (FSPEvent *)[context existingObjectWithID:eventId error:nil];
        if (!event)
            return;

        NSParameterAssert([event isKindOfClass:FSPEvent.class]);
        
        if ([event.branch isEqualToString:FSPMLBEventBranchType]) {
            [fetcher fetchMLBPitchingMatchupForEventId:event.objectID callback:^(NSDictionary *matchup) {
                
                //TODO: make processing operation
                FSPMLBPitchingMatchupProcessingOperation *operation = [[FSPMLBPitchingMatchupProcessingOperation alloc] initWithEventId:event.objectID
                                                                                                                               pitchers:matchup
                                                                                                                          context:context];
                operation.completionBlock = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        static NSUInteger mask = NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender;
                        NSNotification *note = [NSNotification notificationWithName:FSPDataCoordinatorDidUpdatePitchingMatchupForEventNotification object:self];
                        [[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:NSPostASAP coalesceMask:mask forModes:nil];
                    });
                };
                [self.eventProcessingQueue addOperation:operation];
                [self.eventProcessingQueue addSaveOperation];
            }];
        }
    }];
}

- (void)updateMatchupForUFCEvent:(NSManagedObjectID *)eventId
{
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;
    [context performBlock:^{
        FSPEvent *event = (FSPEvent *)[context existingObjectWithID:eventId error:nil];
        if (!event)
            return;

        NSParameterAssert([event isKindOfClass:FSPEvent.class]);
        
        if ([event.branch isEqualToString:@"UFC"]) {
            [fetcher fetchUFCEventDataForEventId:eventId callback:^(NSDictionary *fightData) {
                FSPUFCMatchupProcessingOperation *operation = [[FSPUFCMatchupProcessingOperation alloc] initWithUFCEventId:event.objectID
                                                                                                               matchupData:fightData
                                                                                                                   context:context];
                operation.completionBlock = ^{
                    //TODO: Send Notification that the data is updated
                };
                [self.eventProcessingQueue addOperation:operation];
                [self.eventProcessingQueue addSaveOperation];
            }];
        }
    }];
}

- (void)updatePreRaceInfoForRacingEvent:(NSManagedObjectID *)eventId
{
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;
    [context performBlock:^{
        FSPEvent *event = (FSPEvent *)[context existingObjectWithID:eventId error:nil];
        if (!event)
            return;

        NSParameterAssert([event isKindOfClass:FSPEvent.class]);
        
        if ([[event baseBranch] isEqualToString:FSPNASCAREventBranchType]) {
            [fetcher fetchPreRaceInfoDataForEventId:eventId callback:^(NSDictionary *raceData) {
                FSPEvent *event = (FSPEvent *)[self.managedObjectContext existingObjectWithID:eventId error:nil];
                
                if (!event || ![event isKindOfClass:[FSPRacingEvent class]]) return;
                
                if (raceData) {
                    FSPRacingEvent * raceEvent = (FSPRacingEvent *)event;
                    [raceEvent populateWithPreRaceDictionary:raceData];
                }
            }];
        }
    }];
}

- (void)updateTennisResultsForEvent:(NSManagedObjectID *)eventId
{
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;
    [context performBlock:^{
        FSPEvent *event = (FSPEvent *)[context existingObjectWithID:eventId error:nil];
        if (!event)
            return;
		
        NSParameterAssert([event isKindOfClass:FSPEvent.class]);
        
		// baseBranch ... doesn't work for tennis
        if ([event viewType] == FSPTennisViewType) {
            [fetcher fetchTennisResultsForEventId:eventId callback:^(NSArray *tournamentData) {
				FSPTennisResultsProcessingOperation *operation = [[FSPTennisResultsProcessingOperation alloc] initWithTournamentData:tournamentData
																															 eventID:eventId context:self.managedObjectContext];
                
				[self.eventProcessingQueue addOperation:operation];
				[self.eventProcessingQueue addSaveOperation];
			}];
		}
	}];
}


- (void)updateInjuryReportForEvent:(NSManagedObjectID *)eventId;
{
    [self.fetcher fetchInjuryReportForEventId:eventId callback:^(NSArray *injuries) {
        NSManagedObjectContext *context = self.managedObjectContext;
        [context performBlock:^{
            FSPEvent *event = (FSPEvent *)[context existingObjectWithID:eventId error:nil];
            if (!event)
                return;

            NSParameterAssert([event isKindOfClass:FSPEvent.class]);
            
            FSPInjuryReportProcessingOperation *operation = [[FSPInjuryReportProcessingOperation alloc] initWithEventId:event.objectID
                                                                                                               injuries:injuries
                                                                                                          context:context];
            operation.completionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    static NSUInteger mask = NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender;
                    NSNotification *note = [NSNotification notificationWithName:FSPDataCoordinatorUpdatedInjuryReportForEventNotification object:self];
                    [[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:NSPostASAP coalesceMask:mask forModes:nil];
                });
            };
            [self.eventProcessingQueue addOperation:operation];
            [self.eventProcessingQueue addSaveOperation];
        }];
    }];
}

#pragma mark - Live Engine
- (void)updateLiveEngineGameDictionaryForEvent:(NSManagedObjectID *)eventId update:(BOOL)update;
{
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;

    [context performBlock:^{
        FSPEvent *event = (FSPEvent *)[context existingObjectWithID:eventId error:nil];
        if (!event)
            return;
        
        NSParameterAssert([event isKindOfClass:FSPEvent.class]);
        
    //TODO: check game dictionary once a day (minimum)
//    if ([event.gameDictionaryCreated boolValue])
//        return;
        
        [fetcher fetchGameDictionaryForEventId:eventId success:^(NSDictionary *gameDictionary) {
            // Process the game dictionary
            FSPGameDictionaryProcessingOperation *operation = [[FSPGameDictionaryProcessingOperation alloc] initWithEventId:event.objectID
                                                                                                             gameDictionary:gameDictionary
                                                                                                              context:context];
            operation.completionBlock = ^{
                [context performBlockAndWait:^{
                    if (gameDictionary) {
                        FSPEvent *updatedEvent = (FSPEvent *)[context existingObjectWithID:eventId error:nil];
                        if (!updatedEvent)
                            return;
                        
                        if (update)
                            [self beginUpdatingLiveEngineMessageBundlesForEvent:eventId liveEngineEventIdentifier:updatedEvent.liveEngineIdentifier];
                    }
                }];
            };
            
            [self.eventProcessingQueue addOperation:operation];
            [self.eventProcessingQueue addSaveOperation];

        } failure:^(NSError *error) {
            FSPLogDataCoordination(@"failed to update game dictionary for event %@", event);
        }];
    }];
}

- (void)beginUpdatingLiveEngineMessageBundlesForEvent:(NSManagedObjectID *)eventId liveEngineEventIdentifier:(NSNumber *)eventIdentifier;
{
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPLiveEngineDataRetrieving> fetcher = self.liveEngineFetcher;
    [context performBlock:^{
        FSPEvent *event = (FSPEvent *)[context existingObjectWithID:eventId error:nil];
        if (!event)
            return;
        
        NSParameterAssert([event isKindOfClass:FSPEvent.class]);

        if (![event.gameDictionaryCreated boolValue])
            return;
        
        //Reset the current update version to get an init bundle
        event.liveEngineUpdatedVersion = @(FSPLiveEngineDefault);
        
		[[FSPPollingCenter defaultCenter] addPollingActionForKey:FSPMessageBundlePollingActionKey timeInterval:FSPDataCoordinatorRetryInterval usingBlock:^{
            [fetcher fetchMessageBundleForEventId:eventId liveEngineIdentifier:eventIdentifier success:^(NSDictionary *messageBundle) {
                
                [context performBlock:^{
                    //Dont keep polling if the game is final
                    NSString * type = [messageBundle objectForKey:@"f_type"];
                    if ([type isEqualToString:@"FINAL"]) {
                        [[FSPPollingCenter defaultCenter] stopPollingActionForKey:FSPMessageBundlePollingActionKey];
                    }
                    
                    NSDictionary *data = [messageBundle objectForKey:@"data"];
                    
                    //TODO: remove this when feed is consistant
                    NSNumber * initIdentifier;
                    id holderInit = [messageBundle fsp_objectForKey:@"init" defaultValue:@(NO)];
                    if ([holderInit isKindOfClass:[NSString class]]) {
                        if ([holderInit isEqualToString:@"true"]) {
                            initIdentifier = @(YES);
                        } else {
                            initIdentifier = @(NO);
                        }
                    } else if ([holderInit isKindOfClass:[NSNumber class]]) {
                        initIdentifier = holderInit;
                    }
                    
                    NSNumber *currentVersion = [messageBundle objectForKey:@"version"];
                    
                    FSPLogDataCoordination(@"version = %@", currentVersion);
                    
                    event.liveEngineUpdatedVersion = currentVersion;
                    
                    if (data && [data count] > 1) { // TODO: check for actual data.. currently returning a <null> as the value of the "data" key
                        //Remove old data if its an init bundle
                        if ([initIdentifier isEqualToNumber:@(YES)]) {
                            if ([event isKindOfClass:[FSPGame class]]) {
                                ((FSPGame *)event).playByPlayItems = nil;
                            }
                        }
                        //Process live engine dictionary
                        FSPMessageBundleProcessingOperation *liveEngineOperation = [[FSPMessageBundleProcessingOperation alloc] initWithEventId:event.objectID
                                                                                                                                  messageBundle:data
                                                                                                                                  context:context];
                        liveEngineOperation.completionBlock = nil;
                        [self.eventProcessingQueue addOperation:liveEngineOperation];
                        [self.eventProcessingQueue addSaveOperation];
                    }
                }];
            } failure:^(NSError *error) {
                FSPLogDataCoordination(@"failed to update message bundle for event %@", event);
            }];
            
        }];
    }];
}

@end
