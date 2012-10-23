//
//  FSPDataCoordinator.h
//  FoxSports
//
//  Created by Chase Latta on 2/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPDataCoordinatorDataRetrieving.h"
#import "FSPStory.h"

@class FSPNewsStory, FSPNewsCity;

/////////////////////////////////
///   Notifications
/////////////////////////////////

extern NSString * const FSPDataCoordinatorErrorDomain;

// All orgs
extern NSString * const FSPAllOrganizationsUpdatedNotification;
extern NSString * const FSPInsertedOrganizationsKey;
extern NSString * const FSPDeletedOrganizationsKey;
extern NSString * const FSPChangedOrganizationsKey;

extern NSString * const FSPAllOrganizationsFailedToUpdateNotification;
extern NSString * const FSPAllOrganizationsFailedErrorKey;

extern NSString * const FSPDataCoordinatorDidUpdateTeamsForOrganizationNotification;
extern NSString * const FSPDataCoordinatorFailedToUpdateTeamsForOrganizationNotification;
extern NSString * const FSPDataCoordinatorUpdatedOrganizationObjectIDKey;
extern NSString * const FSPDataCoordinatorNoEventDataFoundNotification;

// Schedule Updating Notifications
extern NSString * const FSPScheduleDidCompleteBatchUpdateNotification;
extern NSString * const FSPScheduleDidCompleteUpdatingNotification;


typedef enum {
    FSPDataFetcherMockType = 0,
    FSPDataFetcherNetworkType,
    FSPDataFetcherDefaultType = FSPDataFetcherNetworkType
} FSPDataFetcherType;

// Exceptions
extern NSString * const FSPInvalidFetcherTypeException;

@interface FSPDataCoordinator : NSObject

/**
 The fetcher that is currently being used to fetch data.
 */
@property (nonatomic, strong, readonly) id <FSPDataCoordinatorDataRetrieving> fetcher;

/**
 The fetcher that coordinates live engine calls.
 */
@property (nonatomic, strong, readonly) id <FSPLiveEngineDataRetrieving> liveEngineFetcher;

/**
 
 */
@property (nonatomic, strong, readonly) id <FSPPreferencesProtocol> profileClient;

/**
 The top level managed object context that the coordinator will save to.
 The context may create contexts of its own but it will guaruntees that it
 will always save up to this level.
 
 By default the context is a main thread context.
 */
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

/**
 Returns the default coordinator.
 */
+ (id)defaultCoordinator;

+ (id)coordinatorWithFetcherType:(FSPDataFetcherType)type;

/**
 Resets the coordinator so that the next +defaultCoordinator invocation creates a new
 data coordinator.
 */
+ (void)resetCoordinator;

/**
 Initializes the data coordinator with a fetcher of the specified type.
 */
- (id)initWithFetcherType:(FSPDataFetcherType)type;

/**
 * Start polling for config changes.
 */
- (void)beginUpdatingConfiguration;

#pragma mark - Mass Relevance

- (void)updateMassRelevanceForOrganizationId:(NSManagedObjectID *)organizationId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

#pragma mark - Organizations

/**
 Updates all of the organizations.  This method does not update the teams for the given organization and does not
 download logos.
 
 Upon completion the callback will be executed on the main thread and the FSPAllOrganizationsUpdatedNotification 
 will be posted.
 */
- (void)updateAllOrganizationsCallback:(void (^)(BOOL success, NSDictionary *userInfo))callback;

/**
 Updates the teams for all organizations.
 
 The coordinator will post a FSPDataCoordinatorDidUpdateTeamsForOrganizationNotification when the coordinator
 finishes updating an organization's teams.
 Upon completion the callback will be executed on the main thread and the FSPOrganizationDidUpdateTeamsNotification
 will be posted if successful or FSPDataCoordinatorFailedToUpdateTeamsForOrganizationNotification if failed.
 */
- (void)updateAllTeamsForAllOrganizations:(void (^)(BOOL success))callback;

/**
 Updates the schedule for a given organization.  The operation will post the FSPScheduleDidCompleteBatchUpdateNotification when it finishes
 processing a batch of events and will post the FSPScheduleDidCompleteUpdatingNotification when completed.
 */
- (void)updateScheduleForOrganizationId:(NSManagedObjectID *)organizationId;
- (void)updateScheduleForOrganizationId:(NSManagedObjectID *)organizationId success:(void (^)(NSArray *schedule))callback;
- (void)updateScheduleForOrganizationId:(NSManagedObjectID *)organizationId success:(void (^)(NSArray *schedule))callback failure:(void (^)(NSError *error))failure;

/**
 Updates the standings for a given organization(s).
 */
- (void)updateStandingsForOrganizationId:(NSManagedObjectID *)organizationId callback:(void (^)(BOOL success))callback;
- (void)updateStandingsForOrganizationIds:(NSArray *)organizationIds callback:(void (^)(BOOL success))callback;
//fighting events standings
- (void)updateTitleHoldersForOrganizationId:(NSManagedObjectID *)orgId callback:(void (^)(BOOL success))callback;

/**
 Updates poll rankings for a given organization
 */
- (void)updateRankingsForOrganizationId:(NSManagedObjectID *)orgId callback:(void (^)(BOOL success))callback;


#pragma mark - Chips

/**
 Updates chips for a given organization(s)
 */
- (void)beginUpdatingEventsForOrganizationId:(NSManagedObjectID *)organizationId;
- (void)beginUpdatingEventsForOrganizationIds:(NSArray *)organizationIds;
/*
 Stops updating chips for the current organization(s).
 */
- (void)endUpdatingEventsForCurrentOrganizations;


#pragma mark - Flush Methods

/**
 Calling this method removes all of the organizations from the database.
 
 The callback block will contain an array of of NSManagedObjectID objects for all of the removed organizations.
 
 The FSPAllOrganizationsUpdatedNotification will be posted when this is done.
 */
- (void)flushAllOrganizationCallback:(void (^)(BOOL success, NSArray *deletedOrganizationIds))callback;

////////////////////////////////////
///   News
////////////////////////////////////
- (void)updateNewsCities:(void (^)(void))success failure:(void (^)(NSError *error))failure;
#pragma mark - News

- (void)updateTopNewsHeadlines:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)updateNewsHeadlinesForCity:(NSManagedObjectID *)cityID success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)updateNewsHeadlinesForOrganizationId:(NSManagedObjectID *)organization success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

- (void)asynchronouslyLoadNewsStoryForHeadline:(NSManagedObjectID *)headline success:(void (^)(FSPNewsStory *newsObject))success failure:(void (^)(NSError *error))failure;
- (void)asynchronouslyLoadNewsStoryForEvent:(NSManagedObjectID *)eventId storyType:(FSPStoryType)storyType success:(void (^)(FSPNewsStory *newsObjectId))success failure:(void (^)(NSError *error))failure;

#pragma mark -
/*
 Update PGA leaderboard
 */
// TODO: temporary?
- (void)updateLeaderboardForEventIdentifier:(NSString *)eventIdentifier callback:(void (^)(BOOL success))callback;

- (void)updateVideosForOrganizationsIds:(NSArray *)organizations callback:(void (^)(BOOL success))callback;
- (void)updateVideosForEventId:(NSManagedObjectID *)eventID callback:(void (^)(BOOL success))callback;
- (void)getPlatformAuthenticationTokenWithCallback:(void (^)(NSString *token))callback;

@end
