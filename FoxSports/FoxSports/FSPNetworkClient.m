//
//  FSPNetworkClient.m
//  FoxSports
//
//  Created by Chase Latta on 1/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNetworkClient.h"
#import "FSPOrganization.h"
#import "FSPOrganizationHierarchyInfo.h"
#import "FSPEvent.h"
#import "FSPOrganization.h"
#import "FSPCoreDataManager.h"
#import "NSHTTPURLResponse+FSPExtensions.h"
#import "AFHTTPClient.h"
#import "FSPAppDelegate.h"
#import "JSONKit.h"
#import "FSPPlatformPasswordHelper.h"
#import "FSPSettingsBundleHelper.h"
#import "FSPStory.h"
#import "FSPDataCoordinator.h"

#import "NSData+FSPExtensions.h"

NSString * const FSPNetworkClientErrorDomain = @"FSPNetworkClientErrorDomain";

/**
 * The subsection of event details.
 */
typedef enum {
    FSPFetchTypeEventOdds = 0,
    FSPFetchTypeEventInjuryReport,
    FSPFetchTypeEventPreviewStory,
    FSPFetchTypeEventRecapStory
} FSPFetchEventDetailsType;

/**
 * The type of information associated with an organization request
 */
typedef enum {
    FSPFetchTypeOrganizationTeams = 0,
    FSPFetchTypeOrganizationChips,
    FSPFetchTypeOrganizationSchedule,
    FSPFetchTypeOrganizationStandings
} FSPFetchOrganizationDetailsType;

static NSString * FSPFSIDKey = @"fsId";
static NSString * FSPBranchKey = @"branch";
static NSString * FSPItemTypeKey = @"itemType";

static NSString * FSPFetchPathHeadlines = @"/headlines";
static NSString * FSPFetchPathOdds = @"/eventodds";
static NSString * FSPFetchPathInjuries = @"/injuryreport";
static NSString * FSPFetchPathPreviewStory = @"/previewstory";
static NSString * FSPFetchPathRecapStory = @"/recapstory";
static NSString * FSPFetchPathNews = @"/news";
static NSString * FSPFetchPathConfiguration = @"/fsdms/configuration";
static NSString * FSPFetchPathNewsLocations = @"/newslocations";

static NSString * FSPFetchPathOrganizations = @"/organization";
static NSString * FSPFetchPathTeams = @"/teams";
static NSString * FSPFetchPathSchedule = @"/schedule";
static NSString * FSPFetchPathStandings = @"/standings";
static NSString * FSPFetchPathChips = @"/chips";
static NSString * FSPFetchPathGameDictionary = @"/gamedictionary";
static NSString * FSPFetchPathMLBMatchup = @"/baseball/pitching/matchup";
static NSString * FSPFetchPathUFC = @"/fighting/fightEvent";
static NSString * FSPFetchPathPreRace = @"/preraceinfo";
static NSString * FSPFetchPathTitleHolders = @"/titleholders";
static NSString * FSPFetchPathRankings = @"/rankings";

static NSString * FSPNewsTypeKey = @"newsType";
static NSString * FSPParamsMapKey = @"params";
static NSString * FSPTopNewsType = @"TOPNEWS";
static NSString * FSPLocalNewsType = @"LOCALNEWS";
static NSString * FSPRelatedNewsType = @"RELATEDNEWS";

typedef void(^FSPNetworkClientParamsCallback)(id parameters);

@interface FSPNetworkClient () {}

/**
 * Returns an NSDictionary appropriate to pass as parameters to an AFHTTPClient;
 * for use with requests that require organization UID, branch, and item type.
 */
- (void)basicRequestParametersForOrganization:(FSPOrganization *)organization callback:(FSPNetworkClientParamsCallback)callback;
- (void)basicRequestParametersForOrganizationId:(NSManagedObjectID *)organizationId callback:(FSPNetworkClientParamsCallback)callback;

- (void)fetchHeadlinesWithParameters:(NSDictionary *)params success:(void (^)(NSArray *headlines))success failure:(void (^)(NSError *error))failure;

- (void)requestParametersForRankingsOrganizationId:(NSManagedObjectID *)organizationId callback:(FSPNetworkClientParamsCallback)callback;

/**
 * Utility methods for looking up managed objects in the master context.
 */
- (FSPEvent *)eventForId:(NSManagedObjectID *)eventId;
- (FSPOrganization *)organizationForId:(NSManagedObjectID *)organizationId;

/**
 * Making an authentication token request
 */
- (void)requestVideoAuthenticationTokenWithCallback:(void (^)(NSString *))callback;

@end

@implementation FSPNetworkClient

- (NSURL *)currentBaseURL {
    return [NSURL URLWithString:[FSPSettingsBundleHelper appEnvironmentURL]];
}

- (id)init
{
    self = [super initWithBaseURL:[self currentBaseURL]];
    if (self) {
        self.parameterEncoding = AFJSONParameterEncoding;
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - :: Configuration ::
- (void)fetchConfiguration:(void (^)(NSDictionary *configuration))callback;
{
    [self getPath:FSPFetchPathConfiguration parameters:nil success:^(AFHTTPRequestOperation *op, id JSON) {
        if (callback) {
            callback(JSON);
        }
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}


#pragma mark - :: Mass Relevance ::

- (void)fetchMassRelevanceForOrganizationId:(NSManagedObjectID *)orgId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
{                
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://tweetriver.com/SportyTester/", @"7-16-yankees-hashtags-keywords-test.json"]]];
    
    [self enqueueHTTPRequestOperation:[self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) 
                                       {
                                           if ([JSON isKindOfClass:[NSArray class]]) {
                                               if (success)
                                                   success(JSON);
                                           } else {
                                               if (failure) {
                                                   NSError *error = [NSError errorWithDomain:FSPNetworkClientErrorDomain code:FSPErrorInvalidReturnedData userInfo:nil];
                                                   failure(error);
                                               }
                                           }
                                       } 
                                                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) 
                                       {
                                           if (failure)
                                               failure(error);
                                       }
                                       ] 
     ];
        
}

#pragma mark - :: Organizations ::
- (void)fetchOrganizationStructure:(void (^)(NSArray *organizations))callback;
{
    [self getPath:FSPFetchPathOrganizations parameters:nil success:^(AFHTTPRequestOperation *op, id JSON) {
        if (callback) {
            callback(JSON);
        }
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}

- (void)fetchTeamsForOrganizationId:(NSManagedObjectID *)orgId callback:(void (^)(NSArray *))callback;
{
#ifdef DEBUG
    NSDate *startTime = [NSDate date];
    NSString *orgName = [[[[FSPDataCoordinator defaultCoordinator] managedObjectContext] objectWithID:orgId] valueForKey:@"name"];
#endif
    [self.managedObjectContext performBlock:^{
        [self basicRequestParametersForOrganizationId:orgId callback:^(NSArray* parameters) {
            [self postPath:FSPFetchPathTeams parameters:[parameters lastObject] success:^(AFHTTPRequestOperation *operation, id JSON) {
#ifdef DEBUG_xmas_chips
                NSLog(@"TEAMS CALL RETURNED: %@ >>>>> (%fms) \n params: %@", orgName, ABS([startTime timeIntervalSinceNow]), parameters);
#endif
                if (callback)
                    callback(JSON);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
                NSLog(@"TEAMS CALL FAILED: %@ >>>>> (%fms) \n params: %@", orgName, ABS([startTime timeIntervalSinceNow]), parameters);
#endif
                if (callback)
                    callback(nil);
            }];
        }];
    }];
}

- (void)fetchScheduleForOrganizationId:(NSManagedObjectID *)orgId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
{
    if (orgId) {
        [self.managedObjectContext performBlock:^{
            [self basicRequestParametersForOrganizationId:orgId callback:^(NSArray* parameters) {
                for (NSDictionary *params in parameters) {
                    [self postPath:FSPFetchPathSchedule parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                        if ([JSON isKindOfClass:[NSArray class]]) {
                            if (success)
                                success(JSON);
                        } else {
                            if (failure) {
                                NSError *error = [NSError errorWithDomain:FSPNetworkClientErrorDomain code:FSPErrorInvalidReturnedData userInfo:nil];
                                failure(error);
                            }
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        if (failure)
                            failure(error);
                    }];
                }
            }];
        }];
    } else {
        FSPLogFetching(@"Couldn't find organization for id %@", orgId);
    }
}

- (void)fetchStandingsForOrganizationId:(NSManagedObjectID *)orgId callback:(void (^)(NSArray *))callback
{
    [self.managedObjectContext performBlock:^{
        [self basicRequestParametersForStandingsOrganizationId:orgId callback:^(NSArray* parameters) {
            NSDictionary *params = [parameters lastObject];
            [self postPath:FSPFetchPathStandings parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                if (callback)
                    callback(JSON);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (callback)
                    callback(nil);
            }];
        }];
    }];
}

#pragma mark - :: Chips ::
- (void)fetchEventsForOrganizationId:(NSManagedObjectID *)organizationId callback:(void (^)(NSArray *events))callback;
{
    [self fetchEventsForOrganizationIds:@[organizationId] callback:callback];
}

- (void)fetchEventsForOrganizationIds:(NSArray *)organizationIds callback:(void (^)(NSArray *events))callback
{
    
#ifdef DEBUG
    NSDate *startTime = [NSDate date];
    NSMutableArray *orgNames = NSMutableArray.new;
    for (id orgId in organizationIds) {
        [orgNames addObject:[[[[FSPDataCoordinator defaultCoordinator] managedObjectContext] objectWithID:orgId] valueForKey:@"name"]];
    }

#if 0
    if (organizationIds.count) {
        NSLog(@"multiple orgs trying to get teams at once: %@", [orgNames componentsJoinedByString:@","]);
    }
#endif
    
#endif
    
    if (organizationIds.count == 0) {
        FSPLogFetching(@"Tried to fetch details for an empty list of organizations");
        return;
    } else if (organizationIds.count == 1) {
        [self basicRequestParametersForOrganizationId:[organizationIds lastObject] callback:^(NSArray* parameters) {
#ifdef DEBUG_xmas_chips
            NSLog(@"BULK CALL BEING MADE: %@ >>>>> (%fms) \n params: %@", [orgNames componentsJoinedByString:@","], ABS([startTime timeIntervalSinceNow]), parameters);
#endif
            NSString *path = FSPFetchPathChips;
            id params;
            if (parameters.count > 1) {
                path = [path stringByAppendingString:@"/bulk"];
                params = parameters;
            } else {
                params = [parameters lastObject];
            }
            [self postPath:path parameters:(id)params success:^(AFHTTPRequestOperation *operation, id JSON) {
#ifdef DEBUG_xmas_chips
                NSLog(@"BULK CALL RETURNED: %@ >>>>> (%fms) \n params: %@", [orgNames componentsJoinedByString:@","], ABS([startTime timeIntervalSinceNow]), parameters);
#endif
                if (callback)
                    callback(JSON);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
                NSLog(@"BULK CALL FAILED: %@ >>>>> (%fms) \n params: %@", [orgNames componentsJoinedByString:@","], ABS([startTime timeIntervalSinceNow]), parameters);
#endif
                if (callback)
                    callback(nil);
            }];
        }];
	} else {
        NSString *postPath = [FSPFetchPathChips stringByAppendingString:@"/bulk"];
        [self basicRequestParametersForOrganizationIds:organizationIds callback:^(NSArray* parameters) {
            [self postPath:postPath parameters:(id)parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
#ifdef DEBUG_xmas_chips
                NSLog(@"CHIP CALL RETURNED: %@ >>>>> (%fms) \n params: %@", [orgNames componentsJoinedByString:@","], ABS([startTime timeIntervalSinceNow]), parameters);
#endif
                if (callback)
                    callback(JSON);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
                NSLog(@"CHIP CALL FAILED: %@ >>>>> (%fms) \n params: %@", [orgNames componentsJoinedByString:@","], ABS([startTime timeIntervalSinceNow]), parameters);
#endif
                if (callback)
                    callback(nil);
            }];
        }];
	}
}

#pragma mark - :: News ::

- (void)fetchTopNewsHeadlines:(void (^)(NSArray *headlines))success failure:(void (^)(NSError *error))failure;
{
    NSDictionary *params = @{FSPNewsTypeKey: FSPTopNewsType};
    [self fetchHeadlinesWithParameters:params success:success failure:failure];
}

- (void)fetchLocalNewsHeadlinesForCityId:(NSString *)cityId success:(void (^)(NSArray *headlines))success failure:(void (^)(NSError *error))failure;
{
    NSDictionary *params = @{@"cityID": cityId};
    NSDictionary *requestParams = @{FSPNewsTypeKey: FSPLocalNewsType,
                                   FSPParamsMapKey: params};
    [self fetchHeadlinesWithParameters:requestParams success:success failure:failure];
}

- (void)fetchLocalNewsHeadlinesForAffiliateId:(NSString *)affiliateId success:(void (^)(NSArray *headlines))success failure:(void (^)(NSError *error))failure;
{
    NSDictionary *params = @{@"affiliateID": affiliateId};
    NSDictionary *requestParams = @{FSPNewsTypeKey: FSPLocalNewsType,
                                   FSPParamsMapKey: params};
    [self fetchHeadlinesWithParameters:requestParams success:success failure:failure];
}

- (void)fetchRelatedNewsHeadlinesForOrganizationId:(NSManagedObjectID *)organizationId success:(void (^)(NSArray *headlines))success failure:(void (^)(NSError *error))failure;
{
    [self.managedObjectContext performBlock:^{
        [self basicRequestParametersForOrganizationId:organizationId callback:^(NSArray* orgParams) {
            for (NSDictionary *dict in orgParams) {
                NSDictionary *requestParams = @{FSPNewsTypeKey: FSPRelatedNewsType,
                                           FSPParamsMapKey: dict};
                [self fetchHeadlinesWithParameters:requestParams success:success failure:failure];
            }
        }];
    }];
}

- (void)fetchHeadlinesWithParameters:(NSDictionary *)params success:(void (^)(NSArray *headlines))success failure:(void (^)(NSError *error))failure;
{
    [self postPath:FSPFetchPathHeadlines parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Make sure that we are getting an array
        if ([responseObject isKindOfClass:[NSArray class]]) {
            if (success)
                success(responseObject);
        } else {
            FSPLogFetching(@"fetched headlines %@ is not returned as an array", responseObject);
            if (success)
                success(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
            failure(error);
    }];
}

- (void)fetchNewsStoryWithIdentifier:(NSString *)identifier success:(void (^)(NSDictionary *storyObject))success failure:(void (^)(NSError *error))failure;
{
    NSDictionary *params = @{@"newsId": identifier};
    [self postPath:FSPFetchPathNews parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if (![responseObject isKindOfClass:[NSDictionary class]])
            responseObject = nil;
        
        NSTimeInterval cacheDuration = [[operation response] fsp_cacheDuration];
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:cacheDuration];
        NSMutableDictionary *mutableResponse = [responseObject mutableCopy];
        [mutableResponse setObject:expirationDate forKey:@"expirationDate"];
        responseObject = [NSDictionary dictionaryWithDictionary:mutableResponse];
        if (success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
            failure(error);
    }];
}

- (void)fetchStoryForEventId:(NSManagedObjectID *)eventId storyType:(FSPStoryType)storyType success:(void (^)(NSDictionary *storyObject))success failure:(void (^)(NSError *error))failure;
{
#ifdef DEBUG
    NSParameterAssert(eventId);
#endif
    
    [self requestParametersForEventId:eventId callback:^(NSDictionary *parameters) {
        
        NSString *fetchPath = nil;
        switch (storyType) {
            case FSPStoryTypePreview:
                fetchPath = FSPFetchPathPreviewStory;
                break;
            case FSPStoryTypeRecap:
                fetchPath = FSPFetchPathRecapStory;
                break;
            default:
                break;
        }
        
        [self postPath:fetchPath parameters:parameters success:^(AFHTTPRequestOperation *op, id JSON) {
            if (success) {
                success(JSON);
            }
        } failure:^(AFHTTPRequestOperation *op, NSError *error) {
            
            NSLog(@"no data for path: %@ \n params: %@", fetchPath, parameters);
            
            if (failure)
                failure(nil);
        }];
    }];
}

- (void)fetchNewsCities:(void (^)(NSDictionary *newsCities))success failure:(void (^)(NSError *error))failure
{
    [self getPath:FSPFetchPathNewsLocations parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if (![responseObject isKindOfClass:[NSDictionary class]])
            responseObject = nil;
        NSTimeInterval cacheDuration = [[operation response] fsp_cacheDuration];
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:cacheDuration];
        NSMutableDictionary *mutableResponse = [responseObject mutableCopy];
        [mutableResponse setObject:expirationDate forKey:@"expirationDate"];
        responseObject = [NSDictionary dictionaryWithDictionary:mutableResponse];
        if (success)
            success(responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
            failure(error);
    }];
}

#pragma mark - :: Event Details ::


- (void)fetchEventOddsForEventId:(NSManagedObjectID *)eventId callback:(void (^)(NSArray *))callback
{
    if (eventId) {
        [self.managedObjectContext performBlock:^{
            [self requestParametersForEventId:eventId callback:^(NSDictionary *parameters) {
                [self postPath:FSPFetchPathOdds parameters:parameters success:^(AFHTTPRequestOperation *op, id JSON) {
                    if (callback) {
                        callback(JSON);
                    }
                } failure:^(AFHTTPRequestOperation *op, NSError *error) {
                    if (callback)
                        callback(nil);
                }];
            }];
        }];
    }
}

- (void)fetchInjuryReportForEventId:(NSManagedObjectID *)eventId callback:(void (^)(NSArray *))callback
{
    if (eventId) {
        [self.managedObjectContext performBlock:^{
            [self requestParametersForEventId:eventId callback:^(NSDictionary *parameters) {
                [self postPath:FSPFetchPathInjuries parameters:parameters success:^(AFHTTPRequestOperation *op, id JSON) {
                    if (callback) {
                        callback(JSON);
                    }
                } failure:^(AFHTTPRequestOperation *op, NSError *error) {
                    if (callback)
                        callback(nil);
                }];
            }];
        }];
    }
}

- (void)fetchMLBPitchingMatchupForEventId:(NSManagedObjectID *)eventIdentifier callback:(void (^)(NSDictionary *matchup))callback
{
    if (eventIdentifier) {
        [self.managedObjectContext performBlock:^{
            [self requestParametersForEventId:eventIdentifier callback:^(NSDictionary *parameters) {
                [self postPath:FSPFetchPathMLBMatchup parameters:parameters success:^(AFHTTPRequestOperation *op, id JSON) {
                    if (callback) {
                        callback(JSON);
                    }
                } failure:^(AFHTTPRequestOperation *op, NSError *error) {
                    if (callback)
                        callback(nil);
                }];
            }];
        }];
    }
}

- (void)fetchUFCEventDataForEventId:(NSManagedObjectID *)eventIdentifier callback:(void (^)(NSDictionary *))callback
{
    if (eventIdentifier) {
        [self.managedObjectContext performBlock:^{
           [self requestParametersForEventId:eventIdentifier callback:^(NSDictionary *parameters) {
               [self postPath:FSPFetchPathUFC parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   if (callback)
                       callback(responseObject);
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   if (callback)
                       callback(nil);
               }];
           }];
        }];
    }
}

- (void)fetchUFCTitleholdersForOrgId:(NSManagedObjectID *)orgId callback:(void (^)(NSArray *))callback
{
    if (orgId) {
        [self.managedObjectContext performBlock:^{
            [self basicRequestParametersForStandingsOrganizationId:orgId callback:^(NSArray* parameters) {
                for (NSDictionary *individualParams in parameters) {
                    [self postPath:FSPFetchPathTitleHolders parameters:individualParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        if (callback)
                            callback(responseObject);
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        if (callback)
                            callback(nil);
                    }];
                }
            }];
        }];
    }
}

- (void)fetchPreRaceInfoDataForEventId:(NSManagedObjectID *)eventIdentifier callback:(void (^)(NSDictionary *raceData))callback;
{
    if (eventIdentifier) {
        [self.managedObjectContext performBlock:^{
            [self requestParametersForEventId:eventIdentifier callback:^(NSDictionary *parameters) {
                [self postPath:FSPFetchPathPreRace parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if (callback)
                        callback(responseObject);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if (callback)
                        callback(nil);
                }];
            }];
        }];
    }
}

- (void)fetchTennisResultsForEventId:(NSManagedObjectID *)eventIdentifier callback:(void (^)(NSArray *data))callback;
{
    if (eventIdentifier) {
        [self.managedObjectContext performBlock:^{
            [self requestParametersForEventId:eventIdentifier callback:^(NSDictionary *parameters) {
                [self postPath:@"/results/tournament/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if (callback)
                        callback(responseObject);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if (callback)
                        callback(nil);
                }];
            }];
        }];
    }
}

- (void)fetchRankingsForOrganization:(NSManagedObjectID *)organizationId callback:(void (^)(NSDictionary *rankingsData))callback;
{
    if (organizationId) {
        [self.managedObjectContext performBlock:^{
            [self requestParametersForRankingsOrganizationId:organizationId callback:^(NSDictionary *parameters) {
                [self postPath:FSPFetchPathRankings parameters:parameters success:^(AFHTTPRequestOperation *op, id JSON) {
                    if (callback) {
                        callback(JSON);
                    }
                } failure:^(AFHTTPRequestOperation *op, NSError *error) {
                    if (callback)
                        callback(nil);
                }];
            }];
        }];
    }
}

- (FSPEvent *)eventForId:(NSManagedObjectID *)eventId {
    return eventId ? (FSPEvent *)[self.managedObjectContext existingObjectWithID:eventId error:nil] : nil;
}

- (FSPOrganization *)organizationForId:(NSManagedObjectID *)organizationId {
    return organizationId ? (FSPOrganization *)[self.managedObjectContext existingObjectWithID:organizationId error:nil] : nil;
}

- (void)requestParametersForEventId:(NSManagedObjectID *)eventId callback:(FSPNetworkClientParamsCallback)callback {
    if (eventId && callback) {
        [self.managedObjectContext performBlock:^{
            FSPEvent *event = (id)[self.managedObjectContext existingObjectWithID:eventId error:nil];
            if (event) {
                NSString *fsId = event.uniqueIdentifier;
                NSString *branch = event.branch;
                NSString *itemType = event.itemType;
                if (fsId && branch && itemType) {
                    NSDictionary *parameters = @{
                        FSPFSIDKey: fsId,
                        FSPEventBranchKey: branch,
                        FSPEventItemTypeKey: itemType
                    };
                    callback(parameters);
                }
            }
        }];
    }
}

- (void)requestParametersForRankingsOrganizationId:(NSManagedObjectID *)organizationId callback:(FSPNetworkClientParamsCallback)callback {
    if (organizationId && callback) {
        [self.managedObjectContext performBlock:^{
            FSPOrganization *organization = [self organizationForId:organizationId];
            if (organization) {
                NSDictionary *parameters = @{FSPFSIDKey: organization.uniqueIdentifier,
                FSPEventBranchKey: organization.branch,
                // Needs to always be SPORT
                FSPEventItemTypeKey:@"SPORT"};
                callback(parameters);
            }
        }];
    }
}

- (void)basicRequestParametersForOrganization:(FSPOrganization *)organization callback:(FSPNetworkClientParamsCallback)callback {
    if (organization) {
        [self.managedObjectContext performBlock:^{
            NSMutableArray *parameters = [NSMutableArray array];
            if (organization.currentHierarchyInfo.count) {
                for (FSPOrganizationHierarchyInfo *info in organization.currentHierarchyInfo) {
                    
                    NSDictionary *currentParams = @{FSPFSIDKey: organization.uniqueIdentifier,
                                                    FSPEventBranchKey: info.branch,
                                                    FSPEventItemTypeKey: info.currentOrg.type};
                    [parameters addObject:currentParams];
                }
            }
            if (callback) {
                callback(parameters);
            }
        }];
    }
}

- (void)basicRequestParametersForStandingsOrganizationId:(NSManagedObjectID *)orgId callback:(FSPNetworkClientParamsCallback)callback {
    [self.managedObjectContext performBlock:^{
        FSPOrganization *organization = [self organizationForId:orgId];
        if (organization) {
            NSMutableArray *parameters = [NSMutableArray array];
            //Only one will ever be returned
            if (organization.currentHierarchyInfo.count) {
                FSPOrganizationHierarchyInfo *highestLevel = [organization highestLevel];
                FSPOrganization *org = [organization.type isEqualToString:FSPOrganizationTeamType] ? highestLevel.parentOrg : highestLevel.currentOrg;
				if ([org.type isEqualToString:FSPOrganizationConferenceType]) {
					org = [[org highestLevel] parentOrg];
				}
                NSDictionary *currentParams = @{FSPFSIDKey: org.uniqueIdentifier,
                                            FSPEventBranchKey: org.branch,
                                            FSPEventItemTypeKey: org.type};
                [parameters addObject:currentParams];
            }
            if (callback) {
                callback(parameters);
            }
        }
    }];
}

- (void)basicRequestParametersForOrganizationIds:(NSArray *)organizationIds callback:(FSPNetworkClientParamsCallback)callback {
    if (organizationIds) {
        [self.managedObjectContext performBlock:^{
            NSMutableArray *parameters = [NSMutableArray new];
            for (NSManagedObjectID *organizationId in organizationIds) {
                FSPOrganization *organization = (FSPOrganization *)[self.managedObjectContext existingObjectWithID:organizationId error:nil];
                if (!organization)
                    return;
                [parameters addObject:@{FSPFSIDKey: organization.uniqueIdentifier,
                                            FSPEventBranchKey: organization.branch,
                                            FSPEventItemTypeKey: organization.type}];
            }
            if (callback) {
                callback(parameters);
            }
        }];
    }
}

- (void)basicRequestParametersForOrganizationId:(NSManagedObjectID *)organizationId callback:(FSPNetworkClientParamsCallback)callback {
    [self.managedObjectContext performBlock:^{
        [self basicRequestParametersForOrganization:[self organizationForId:organizationId] callback:callback];
    }];
}

- (void)fetchGameDictionaryForEventId:(NSManagedObjectID *)eventId success:(void (^)(NSDictionary *gameDictionary))success failure:(void (^)(NSError *error))failure {
    [self.managedObjectContext performBlock:^{
        FSPEvent *event = [self eventForId:eventId];
        if (event) {
            NSDictionary *params = @{FSPFSIDKey: event.uniqueIdentifier, FSPBranchKey: event.branch, FSPItemTypeKey: event.itemType};
            [self postPath:FSPFetchPathGameDictionary parameters:params success:^(AFHTTPRequestOperation *op, id response) {
                if (success && [response isKindOfClass:[NSDictionary class]])
                    success(response);
            } failure:^(AFHTTPRequestOperation *op, NSError *error) {
                if (failure)
                    failure(error);
            }];
        } else {
            FSPLogFetching(@"Couldn't find event for id %@", eventId);
        }
    }];
}

#pragma mark - :: Video ::
- (void)fetchAllVideosCallback:(void (^)(NSDictionary *videos))callback;
{
    NSString *path = @"http://feed.theplatform.com/f/fs2go-staging/e8cAFzepUIGu";
//    NSString *path = @"http://feed.theplatform.com/f/fKc3BC/IOS_Everything_Feed";
    [self postPath:path parameters:nil success:^(AFHTTPRequestOperation *op, id JSON) {
        if (callback)
            callback(JSON);
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        if (callback)
            callback(nil);
    }];
}

- (void)fetchVideosForFSID:(NSString *)FSID ofType:(NSString *)objType callback:(void (^)(NSDictionary *))callback
{
	NSString *garble = nil;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		garble = @"5VR8mozZCYYM";
	} else {
		garble = @"WuS5BDhztVRD";
	}

	NSString *path = [[NSString stringWithFormat:@"http://feed.theplatform.com/f/fs2go-staging/%@?byCustomValue={delivery}{VOD},{authenticated}{false},{%@}{%@}", garble, objType, FSID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[self postPath:path parameters:nil success:^(AFHTTPRequestOperation *op, id JSON) {
        if (callback)
            callback(JSON);
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        if (callback)
            callback(nil);
    }];
	
}

- (void)fetchVideosForOrganizationIds:(NSArray *)organizations callback:(void (^)(NSDictionary *videos))callback;
{
	// TODO: possibly? support more-than-one organization
	NSString *orgType = nil;
	FSPOrganization *org = (FSPOrganization *)[self.managedObjectContext existingObjectWithID:[organizations objectAtIndex:0] error:nil];
    if (!org)
        return;
	if ([org.type isEqualToString:@"SPORT"]) {
		orgType = @"sportID";
	} else if ([org.type isEqualToString:@"TEAM"]) {
		orgType = @"teamIDs";
	} else {
		NSLog(@"error; don't know how to handle org of type %@", org.type);
	}
	[self fetchVideosForFSID:org.uniqueIdentifier ofType:orgType callback:callback];
}

- (void)fetchVideosForEventId:(NSManagedObjectID *)eventID callback:(void (^)(NSDictionary *videos))callback;
{
	FSPEvent *event = (FSPEvent *)[self.managedObjectContext existingObjectWithID:eventID error:nil];
    if (!event)
        return;
	[self fetchVideosForFSID:event.uniqueIdentifier ofType:@"eventID" callback:callback];
}

- (void)fetchVideoAuthenticationTokenWithCallback:(void (^)(NSString *authToken))callback
{
    NSString *currentToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"VideoAuthenticationToken"];

    if(currentToken) {
        NSDate *expiryDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"VideoAuthenticationTokenExpiration"];
        FSPLogVideo(@"thePlatform token expiration date: %@", expiryDate);
        if ([[expiryDate laterDate:[NSDate date]] isEqualToDate:expiryDate]) {
            callback(currentToken);
            return;
        }
        else {
            FSPLogVideo(@"Token expired.  Requesting new token");
            [self flushVideoAuthenticationToken:currentToken callback:^(NSDictionary *response) {
                if ([[response allKeys] containsObject:@"signOutResponse"]) {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VideoAuthenticationToken"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VideoAuthenticationTokenExpiration"];
                    [self requestVideoAuthenticationTokenWithCallback:callback];
                }
            }];
        }
    }
    else {
        FSPLogVideo(@"No token found in defaults.  Requesting new token");
        [self requestVideoAuthenticationTokenWithCallback:callback];
    }
}

- (void)requestVideoAuthenticationTokenWithCallback:(void (^)(NSString *))callback
{
    // If a the UUID/username does not exist, create it.
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"appUUID"];
    if (!username) {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        username = (__bridge NSString *)string;
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"appUUID"];
        CFRelease(string);
    }
    
    // The username we use for login is the username we created, with the Directory key prepended.
    NSString *loginUser = [NSString stringWithFormat:@"fs2go-stg-trust/%@", username];
    NSString *password = [FSPPlatformPasswordHelper authenticationPasswordForUserName:username];
    if (!password) {
        NSLog(@"Unable to generate password for token authentication");
        callback(nil);
        return;
    }
    
    NSString *path = @"https://euid.theplatform.com/idm/web/Authentication/signIn?schema=1.0&form=json";
    NSDictionary *params = @{@"username": loginUser, @"password": password};
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *op, id JSON) {
        
        // Response dictionary sample:
        // {
        //    signInResponse =     {
        //        duration = 315360000000;
        //        idleTimeout = 14400000;
        //        token = k1qB7L4OijzlHR9oYgiVETDqoMAOgPBE;
        //        userId = "https://euid.theplatform.com/idm/data/User/fs2go-stg-trust/C8F6235A-507E-4BF5-8EC5-35463D9E856A";
        //        userName = "C8F6235A-507E-4BF5-8EC5-35463D9E856A";
        //    };
        NSString *token = nil;
        if ([JSON isKindOfClass:[NSDictionary class]]) {
            NSDictionary *signInResponse = [JSON objectForKey:@"signInResponse"];
            if (signInResponse) {
                FSPLogVideo(@"thePlatform authentication token response dictionary: %@", signInResponse);
                token = [signInResponse objectForKey:@"token"];
                NSNumber *tokenDuration = [signInResponse objectForKey:@"duration"];
                if (token) {
                    [[NSUserDefaults standardUserDefaults] setObject:[signInResponse objectForKey:@"token"] forKey:@"VideoAuthenticationToken"];
                }
                if (tokenDuration) {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:[tokenDuration integerValue]/1000]
                                                              forKey:@"VideoAuthenticationTokenExpiration"];
                }
            }
        }
        if (callback) {
            callback(token);
        }
    }
          failure:^(AFHTTPRequestOperation *op, NSError *error) {
              if (callback) {
                  callback(nil);
              }
          }];
}

- (void)flushVideoAuthenticationToken:(NSString *)token callback:(void (^)(NSDictionary *))callback
{
    NSString *path = @"https://identity.auth.theplatform.com/idm/web/Authentication?schema=1.0";
    NSDictionary *params = @{ @"signOut" : @{ @"token" : token } };
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *op, id JSON) {
        if (callback) {
            FSPLogVideo(@"thePlatform authentication signout dictionary %@", JSON);
            callback(JSON);
        }
    }
    failure:^(AFHTTPRequestOperation *op, NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}


#pragma mark - :: UNIMPLEMENTED METHODS ::
- (void)fetchStreamabilityForEventIds:(NSArray *)eventIds callback:(void (^)(NSDictionary *streamabilityInfo))callback {
    if (callback)
        callback(nil);
}

- (void)fetchAffiliatesForEventIds:(NSArray *)eventIds callback:(void (^)(NSDictionary *))callback {
    if (callback)
        callback(nil);
}

@end
