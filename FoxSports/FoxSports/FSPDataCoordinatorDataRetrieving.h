//
//  FSPDataCoordinatorDataRetrievelProtocol.h
//  FoxSports
//
//  Created by Chase Latta on 2/17/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPStory.h"

/**
 This protocol is meant to be implemented by objects that fetch data for the data 
 coordinator.
 
 Note that managed objects are always passed indirectly. View controllers and fetch request
 controllers operate on model objects in the GUI context, which should be treated as read-only;
 background processing related to feeds operates on children of the master context. This is
 made explicit here in the FSPDataCoordinatorDataRetrieving API, since this is the point at which
 mapping between contexts occurs.
 */
@protocol FSPDataCoordinatorDataRetrieving <NSObject>

/**
 The request to fetch configuration information, such as the last time logos were updated.
 */

- (void)fetchConfiguration:(void (^) (NSDictionary *configuration))callback;

/**
 The request to fetch all of the organizations.
 
 This does not return any teams.
 */
- (void)fetchOrganizationStructure:(void (^)(NSArray *organizations))callback;

/**
 Fetch the teams for a given organization.
 */
- (void)fetchTeamsForOrganizationId:(NSManagedObjectID *)orgId callback:(void (^)(NSArray *teamIds))callback;

#pragma mark - Mass Relevance

- (void)fetchMassRelevanceForOrganizationId:(NSManagedObjectID *)orgId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

#pragma mark Event Detail fetching

/**
 Fetch the array of event odds for the given event.
 */
- (void)fetchEventOddsForEventId:(NSManagedObjectID *)eventId callback:(void (^)(NSArray *))callback;

/*
 Retrieve the streamability of given events.
 */
- (void)fetchStreamabilityForEventIds:(NSArray *)eventIds callback:(void (^)(NSDictionary *streamabilityInfo))callback;

/*
 Retrieve the television affiliate for given events.
 */
- (void)fetchAffiliatesForEventIds:(NSArray *)eventIds callback:(void (^)(NSDictionary *affiliateIfno))callback;


/*
 Get Injury Report for an event
 */
- (void)fetchInjuryReportForEventId:(NSManagedObjectID *)eventId callback:(void (^)(NSArray *injuries))callback;

/*
 Get story for an event
 */
- (void)fetchStoryForEventId:(NSManagedObjectID *)eventId storyType:(FSPStoryType)storyType success:(void (^)(NSDictionary *storyObject))success failure:(void (^)(NSError *error))failure;

#pragma mark Organization Detail fetching
/**
 Return all of the events for a given organization.  This information should be the lowest level of
 information needed to display the organizations schedule.
 
 org could indicate a team or an organization.
 */
- (void)fetchScheduleForOrganizationId:(NSManagedObjectID *)orgId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

/**
 Retrieve an array of team standings objects and return it in the callback.
 */
- (void)fetchStandingsForOrganizationId:(NSManagedObjectID *)orgId callback:(void (^)(NSArray *standings))callback;

/*
 Retrieve an array of events for a given organization(s).
 */
- (void)fetchEventsForOrganizationId:(NSManagedObjectID *)organizationId callback:(void (^)(NSArray *eventIds))callback;
- (void)fetchEventsForOrganizationIds:(NSArray *)organizationIds callback:(void (^)(NSArray *eventIds))callback;

#pragma mark  - Live Engine
/**
 Retrieve the game dictionary for a given event.
 */
- (void)fetchGameDictionaryForEventId:(NSManagedObjectID *)eventId success:(void (^)(NSDictionary *gameDictionary))success failure:(void (^)(NSError *error))failure;

#pragma mark - News

/**
 Retrieve the list of news cities.
 */
- (void)fetchNewsCities:(void (^)(NSDictionary *newsCities))success failure:(void (^)(NSError *error))failure;

/**
 Retrieve the current top news headlines.
 */
- (void)fetchTopNewsHeadlines:(void (^)(NSArray *headlines))success failure:(void (^)(NSError *error))failure;

/**
 Retrieve the current local headlines for the given city.  The request requires a city id to identify the city.
 */
- (void)fetchLocalNewsHeadlinesForCityId:(NSString *)cityId success:(void (^)(NSArray *headlines))success failure:(void (^)(NSError *error))failure;

/**
 Retrieve the current local headlines for the given affiliate.  The request requires an affiliate id to identify the affiliate.
 */
- (void)fetchLocalNewsHeadlinesForAffiliateId:(NSString *)affiliateId success:(void (^)(NSArray *headlines))success failure:(void (^)(NSError *error))failure;

/**
 Fetches related news for a given organization.  This request will work for both organizations and teams.
 */
- (void)fetchRelatedNewsHeadlinesForOrganizationId:(NSManagedObjectID *)organizationId success:(void (^)(NSArray *headlines))success failure:(void (^)(NSError *error))failure;

- (void)fetchNewsStoryWithIdentifier:(NSString *)identifier success:(void (^)(NSDictionary *storyObject))success failure:(void (^)(NSError *error))failure;

#pragma mark Other fetching

/*
 Get Injury Report for an event
 */
- (void)fetchInjuryReportForEventId:(NSManagedObjectID *)eventIdentifier callback:(void (^)(NSArray *injuries))callback;

/*
 Get pitching matchup for MLB
 */
- (void)fetchMLBPitchingMatchupForEventId:(NSManagedObjectID *)eventIdentifier callback:(void (^)(NSDictionary *matchup))callback;

/*
 Get fight data for UFC
 */
- (void)fetchUFCEventDataForEventId:(NSManagedObjectID *)eventIdentifier callback:(void (^)(NSDictionary *fightData))callback;

/*
 Get title holders for UFC
 */
- (void)fetchUFCTitleholdersForOrgId:(NSManagedObjectID *)orgId callback:(void (^)(NSArray *))callback;

/*
 Get pre race data for racing events (right now only NASCAR implemented)
 */
- (void)fetchPreRaceInfoDataForEventId:(NSManagedObjectID *)eventIdentifier callback:(void (^)(NSDictionary *raceData))callback;

- (void)fetchRankingsForOrganization:(NSManagedObjectID *)organizationId callback:(void (^)(NSDictionary *rankingsData))callback;

// tennis
- (void)fetchTennisResultsForEventId:(NSManagedObjectID *)eventIdentifier callback:(void (^)(NSArray *raceData))callback;


/*
 Get all videos
 */
//TODO: Temporary till we find a better spot for it
- (void)fetchAllVideosCallback:(void (^)(NSDictionary *videos))callback;
- (void)fetchVideosForOrganizationIds:(NSArray *)organizations callback:(void (^)(NSDictionary *videos))callback;
- (void)fetchVideosForEventId:(NSManagedObjectID *)eventID callback:(void (^)(NSDictionary *videos))callback;
- (void)fetchVideoAuthenticationTokenWithCallback:(void (^)(NSString *authToken))callback;
@end

@protocol FSPLiveEngineDataRetrieving <NSObject>

/**
 Retrieve message bundle delta (requires game dictionary)
 */
- (void)fetchMessageBundleForEventId:(NSManagedObjectID *)eventId liveEngineIdentifier:(NSNumber *)liveEngineIdentifier success:(void (^)(NSDictionary *messageBundle))success failure:(void (^)(NSError *error))failure;

/**
 Retrieve Live Engine Chip Feed data (requires game dictionary)
 */
- (void)fetchLiveEngineChipsForOrganizationId:(NSManagedObjectID *)orgId success:(void (^)(NSDictionary *events))success failure:(void (^)(NSError *error))failure;

@end


@protocol FSPPreferencesProtocol

- (void)createProfile:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;
- (void)subscribeToAlertForEvent:(NSManagedObjectID *)eventId preferences:(NSDictionary *)prefs success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)fetchAlertsWithSuccess:(void (^)(NSArray *alerts))success failure:(void (^)(NSError *error))failure;
@end

