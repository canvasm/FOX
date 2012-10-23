//
//  FSPDataCoordinator+EventUpdating.h
//  FoxSports
//
//  Created by Chase Latta on 3/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPDataCoordinator.h"
#import "FSPStory.h"


/**
 * Updates data for event details related to column C.
 */

@class FSPEvent, FSPGame;

extern NSString * const FSPDataCoordinatorUpdatedInjuryReportForEventNotification;
extern NSString * const FSPDataCoordinatorFailedToUpdateInjuryReportForEventNotification;
extern NSString * const FSPDataCoordinatorInjuryReportObjectIDKey;
/**
 * Posted on completion of fetching & updating odds information
 */
extern NSString * const FSPDataCoordinatorDidUpdateOddsForEventNotification;
extern NSString * const FSPDataCoordinatorDidUpdatePitchingMatchupForEventNotification;


@interface FSPDataCoordinator (EventUpdating)

/*
 Begins updating the extended information about the given event.
 */
- (void)beginUpdatingEvent:(NSManagedObjectID *)eventId;

// Updates the Injury Report for a specific event
- (void)updateInjuryReportForEvent:(NSManagedObjectID *)eventId;

//updates the pitching matchup for an event
- (void)updatePitchingMatchupForMLBGame:(NSManagedObjectID *)gameId;

//updates the static matchup data for a UFC event
- (void)updateMatchupForUFCEvent:(NSManagedObjectID *)eventId;

//updates the static pre race data for a racing event
- (void)updatePreRaceInfoForRacingEvent:(NSManagedObjectID *)eventId;
// update tennis tournament results
- (void)updateTennisResultsForEvent:(NSManagedObjectID *)eventId;

/**
 * Updates the game dictionary for a given event
 */
- (void)updateLiveEngineGameDictionaryForEvent:(NSManagedObjectID *)eventId update:(BOOL)update;
@end
