//
//  FSPEvent.h
//  FoxSports
//
//  Created by Chase Latta on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "FSPOrganization.h"

typedef enum {
    FSPStartDateGroupPast,
    FSPStartDateGroupToday,
    FSPStartDateGroupTomorrow,
    FSPStartDateGroupComingUp
} FSPStartDateGroupIndex;


// Dictionary Required Key Constants
extern NSString * const FSPEventUniqueIdKey;
extern NSString * const FSPEventBranchKey;
extern NSString * const FSPEventItemTypeKey;
extern NSString * const FSPEventStartDateKey;
extern NSString * const FSPEventEventStateKey;
extern NSString * const FSPEventIsStreamableKey;

//Default for Live Engine numbers
extern const int FSPLiveEngineDefault;

@class FSPOrganizationSchedule;
@class FSPStory;
@class FSPVideo;

@interface FSPEvent : NSManagedObject

/**
 The flag specifying if the event should be shown in Col B.
 */
@property (nonatomic, retain) NSNumber *displayInColB;

/**
 The branch for EPAM.
 */
@property (nonatomic, retain) NSString *branch;

/**
 The Item Type of the event.
 */
@property (nonatomic, retain) NSString *itemType;

/**
 An unformatted string indicating the segment that we are 
 currently in.
 */
@property (nonatomic, retain) NSString *segmentNumber; 

/**
 The description of the segment, "12:29" for NHL, "Top" for
 MLB etc.
 */
@property (nonatomic, retain) NSString *segmentDescription;

/**
 The state of the event, FINAL, POSTPONED, IN-PROGRESS, etc.
 */
@property (nonatomic, retain) NSString * eventState;

/**
 The network that this event will be displayed on.
 */
@property (nonatomic, retain) NSString * channelDisplayName;

/**
 A globally unique identifier for this event.
 */
@property (nonatomic, retain) NSString * uniqueIdentifier;

/**
 The events start date.
 */
@property (nonatomic, retain) NSDate * startDate;

/**
 Whether or not this event is streamable or not.
 */
@property (nonatomic, retain) NSNumber * streamable;

/**
 The date that this event will be purged from the database.
 */
@property (nonatomic, retain) NSDate * expiresDate;

/**
 A string indicating what part of the season this event corresponds to.
 */
@property (nonatomic, retain) NSString *seasonState;

/**
 The channels that this event can be seen on.
 */
@property (nonatomic, retain) NSSet *channels; // TODO: Need to convert to Organizations

/**
 The start date of this event with the timestamp normalized to 00:00:00.
 */
@property (nonatomic, retain) NSDate *normalizedStartDate;

/**
 The schedules that this event belongs to.
 */
@property (nonatomic, retain) NSSet *belongedToSchedules;

 /*
 * The event's start timeframe: today, tomorrow, or further in the future.
 */
@property (nonatomic, retain) NSNumber *startDateGroup;

/**
 A boolean indicating whether this event's start time is unknown.
 */
@property (nonatomic, retain) NSNumber *eventTimeTBA;

/**
 The minimum polling interval for the live engine.
 */
@property (nonatomic, retain) NSNumber *minPollingInterval;

/**
 The event's season.
 */
@property (nonatomic, retain) NSNumber *season;

/**
 The year that the event is taking place.
 */
@property (nonatomic, retain) NSNumber *eventYear;

/**
 A BOOL indicating if the event has started yet.  This is true even when the event is finished.
 */
@property (nonatomic, retain) NSNumber *eventStarted;

/**
 A BOOL indicating if the event has completed.
 */
@property (nonatomic, retain) NSNumber *eventCompleted;

/**
 A string indicating the timeStatus display for an event.
 */
@property (nonatomic, copy, readonly) NSString *timeStatus;

/**
 The url to use for live data.
 */
@property (nonatomic, retain) NSString *liveDataURL;

/**
 The base URL for player info.
 */
@property (nonatomic, retain) NSString *playerBaseURL;

/**
 * The preview story for the event.
 */
@property (nonatomic, retain) FSPStory *previewStory;

/**
 * The recap story for the event, typically available after the event has completed. 
 */
@property (nonatomic, retain) FSPStory *recapStory;

/**
 The date corresponding to the first game of this event's week.
 */
@property (nonatomic, retain) NSDate *firstGameTime;

/**
 The week number of the season.
 */
@property (nonatomic, retain) NSNumber *weekNumber;

/**
 A boolean indicating whether the game dictionary has been updated for this event.
 */
@property (nonatomic, retain) NSNumber *gameDictionaryCreated;

/**
 A number indicating the last version recieved from Live Engine.
 */
@property (nonatomic, retain) NSNumber *liveEngineUpdatedVersion;

/**
 A string indicating the ID of this event in Live Engine.
 */
@property (nonatomic, retain) NSNumber *liveEngineIdentifier;

@property (nonatomic, retain) NSSet	*organizations;

@property (nonatomic, readonly) FSPViewType viewType;

@property (nonatomic, retain) NSString *venue;

//The name of the league (MLS, Premier League, etc.)
@property (nonatomic, retain) NSString *compType;

/**
 Videos associated with the Event.
 */
@property (nonatomic, retain) NSSet * videos;

/**
 Populate the event with a given dictionary.
 */
- (void)populateWithDictionary:(NSDictionary *)eventData;

/**
 Returns a naturual language string for the current segment number.
 */
- (NSString *)naturalLanguageStringForSegmentNumber:(NSString *)segmentNumber;

/**
 Populate the event with a given League Game Bundle. (Chips)
 */
- (void)populateWithLeagueGameBundleDictionary:(NSDictionary *)eventData;

/**
 Populate the event with a given League Game Bundle. (Chips)
 */
- (void)populateWithLiveTeamStatsDictionary:(NSDictionary *)eventData;

/**
 Populate the segment number and description of an event with a given dictionary.
 */
- (void)populateSegmentInformationWithDictionary:(NSDictionary *)segmentData;

/**
 Returns the entity name for the given chip type.
 */
+ (NSString *)entityNameForBranchType:(NSString *)branchType;

/**
 Returns the display name for a given startDateGroup.
 */
+ (NSString *)displayNameForStartDateGroup:(NSNumber *)aStartDateGroup;

/**
 Returns the base branch (currently only soccer is changed from branch)
 */
- (NSString *)baseBranch;

/*
 Looks for the organization that matches the branch name of the event. Sometimes it's one of the organizations associated with the event, but right now in the case of things like NASCAR we need to look at the children as well. This is not cached and is calculated each call.
 */
- (FSPOrganization *)getPrimaryOrganization;

/**
 returns the highest level (ordinal) FSPOrginazation
 excludes FSPTeam
 */
- (FSPOrganization *)getTopLevelOrganization;

- (BOOL)isOvertime;

- (NSUInteger)numberOfOvertimes;

- (Class)getMassRelevanceClass;


@end

@interface FSPEvent (CoreDataGeneratedAccessors)

- (void)addBelongedToSchedulesObject:(FSPOrganizationSchedule *)schedule;
- (void)removeBelongedToSchedulesObject:(FSPOrganizationSchedule *)schedule;
- (void)addBelongedToSchedules:(NSSet *)values;
- (void)removeBelongedToSchedules:(NSSet *)values;

- (void)addVideosObject:(FSPVideo *)video;
- (void)removeVideosObject:(FSPVideo *)video;
- (void)addVideos:(NSSet *)values;
- (void)removeVideos:(NSSet *)values;


@end
