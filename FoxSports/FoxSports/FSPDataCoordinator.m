//
//  FSPDataCoordinator.m
//  FoxSports
//
//  Created by Chase Latta on 2/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPDataCoordinator.h"
#import "FSPDataCoordinator_Internal.h"
#import "FSPDataCoordinator+EventUpdating.h"

#import "FSPCoreDataManager.h"
#import "FSPPollingCenter.h"
#import "FSPNetworkClient.h"
#import "FSPLiveEngineClient.h"
#import "FSPProfileClient.h"
#import "FSPConfiguration.h"
#import "FSPImageFetcher.h"

#import "FSPConfigurationProcessingOperation.h"
#import "FSPOrganizationProcessingOperation.h"
#import "FSPScheduleProcessingOperation.h"
#import "FSPStandingsProcessingOperation.h"
#import "FSPRankingsProcessingOperation.h"
#import "FSPEventsProcessingOperation.h"
#import "FSPNewsCityProcessingOperation.h"
#import "FSPRacingStandingsProcessingOperation.h"
#import "FSPEventAffiliateIdentificationProcessingOperation.h"
#import "FSPEventStreamabilityProcessingOperation.h"
#import "FSPTeamProcessingOperation.h"
#import "FSPVideoProcessingOperation.h"
#import "FSPNewsProcessingOperation.h"
#import "FSPLiveEngineChipProcessingOperation.h"
#import "FSPTitleHolderProcessingOperation.h"
#import "FSPGolfStandingsProcessingOperation.h"
#import "FSPChipTeamsProcessingOperation.h"
#import "FSPManagedObjectCache.h"
#import "FSPProcessingOperationQueue.h"
#import "FSPTennisStandingsProcessingOperation.h"

#import "FSPNewsHeadline.h"
#import "FSPNewsStory.h"
#import "FSPNewsCity.h"
#import "FSPAppDelegate.h"
#import "FSPConfigurationPrivate.h"
#import "FSPOrganizationSchedule.h"
#import "FSPOrganization.h"
#import "FSPEvent.h"
#import "FSPTeam.h"
#import "FSPGolfer.h"

#import "NSDate+FSPExtensions.h"


NSTimeInterval FSPConfigurationPollingInterval = 30.0;
NSTimeInterval FSPDataCoordinatorRetryInterval = 5.0;
NSInteger FSPDataCoordinatorMaxRetryCount = 3;

NSString * const FSPDataCoordinatorErrorDomain = @"FSPDataCoordinatorErrorDomain";

// Orgs
NSString * const FSPAllOrganizationsUpdatedNotification = @"FSPAllOrganizationsUpdatedNotification";
NSString * const FSPInsertedOrganizationsKey = @"FSPAllOrganizationsUpdatedNotification";
NSString * const FSPDeletedOrganizationsKey = @"FSPDeletedOrganizationsKey";
NSString * const FSPChangedOrganizationsKey = @"FSPChangedOrganizationsKey";

NSString * const FSPAllOrganizationsFailedToUpdateNotification = @"FSPAllOrganizationsFailedToUpdateNotification";
NSString * const FSPAllOrganizationsFailedErrorKey = @"FSPAllOrganizationsFailedErrorKey";

NSString * const FSPInvalidFetcherTypeException = @"FSPInvalidFetcherTypeException";

NSString * const FSPDataCoordinatorDidUpdateTeamsForOrganizationNotification = @"FSPDataCoordinatorDidUpdateTeamsForOrganizationNotification";
NSString * const FSPDataCoordinatorFailedToUpdateTeamsForOrganizationNotification = @"FSPDataCoordinatorFailedToUpdateTeamsForOrganizationNotification";
NSString * const FSPDataCoordinatorUpdatedOrganizationObjectIDKey = @"FSPDataCoordinatorUpdatedOrganizationObjectIDKey";
NSString * const FSPDataCoordinatorNoEventDataFoundNotification = @"FSPDataCoordinatorNoEventDataFoundNotification";

NSString * const FSPScheduleDidCompleteBatchUpdateNotification = @"FSPScheduleDidCompleteBatchUpdateNotification";
NSString * const FSPScheduleDidCompleteUpdatingNotification = @"FSPScheduleDidCompleteUpdatingNotification";

typedef void(^FSPTeamUpdatingCallbackBlock)(BOOL);

@interface FSPDataCoordinator ()
@property (nonatomic, strong) FSPProcessingOperationQueue *organizationProcessingQueue;
@property (nonatomic, strong) FSPProcessingOperationQueue *scheduleProcessingQueue;
@property (nonatomic, strong) FSPProcessingOperationQueue *standingsProcessingQueue;
@property (nonatomic, strong) FSPProcessingOperationQueue *chipProcessingQueue;
@property (nonatomic, strong) FSPProcessingOperationQueue *newsProcessingQueue;
@property (nonatomic, strong) FSPProcessingOperationQueue *configurationProcessingQueue;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *currentPollingOrganizations;

// Updates event streamability for each event identifier in events array.
- (void)updateStreamabilityForEvents:(NSArray *)events;

// Updates TV affiliate for each event identifier in events array.
- (void)updateTelevisionAffiliateForEventIds:(NSArray *)eventIds organizationIds:(NSArray *)organizationIds;

- (void)updateLiveEngineChipFeedForOrganizationId:(NSManagedObjectID *)organizationId WithTimeInterval:(NSTimeInterval)timeInterval;
- (void)updateChipFeedForOrganizationIds:(NSArray *)organizationIds WithTimeInterval:(NSTimeInterval)timeInterval;

- (void)flushLogosForOrganizations;

@end


@implementation FSPDataCoordinator

- (NSOperationQueue *)organizationProcessingQueue;
{
    if (_organizationProcessingQueue == nil) {
        _organizationProcessingQueue = [[FSPProcessingOperationQueue alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                                      createChildContext:YES];
    }
    return _organizationProcessingQueue;
}

- (NSOperationQueue *)scheduleProcessingQueue;
{
    if (_scheduleProcessingQueue == nil) {
        _scheduleProcessingQueue = [[FSPProcessingOperationQueue alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                                  createChildContext:YES];
    }
    return _scheduleProcessingQueue;
}

- (NSOperationQueue *)eventProcessingQueue;
{
    return self.organizationProcessingQueue;
}

- (NSOperationQueue *)standingsProcessingQueue;
{
    return self.organizationProcessingQueue;
}

- (NSOperationQueue *)chipProcessingQueue
{
    return self.organizationProcessingQueue;
}

- (NSOperationQueue *)newsProcessingQueue;
{
    if (!_newsProcessingQueue) {
        _newsProcessingQueue = [[FSPProcessingOperationQueue alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                              createChildContext:YES];
    }
    return _newsProcessingQueue;
}

- (NSOperationQueue *)configurationProcessingQueue
{
    if (!_configurationProcessingQueue) {
        _configurationProcessingQueue = [[FSPProcessingOperationQueue alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                                       createChildContext:NO];
    }
    return _configurationProcessingQueue;
    
}

#pragma mark - Class Methods

static FSPDataCoordinator *defaultCoordinator = nil;

+ (void)resetCoordinator {
    @synchronized (self) {
        if (defaultCoordinator) {
            [[defaultCoordinator organizationProcessingQueue] cancelAllOperations];
            [[defaultCoordinator scheduleProcessingQueue] cancelAllOperations];
            [[defaultCoordinator newsProcessingQueue] cancelAllOperations];
            [[defaultCoordinator configurationProcessingQueue] cancelAllOperations];
        }
        defaultCoordinator = nil;
    }
}

+ (id)defaultCoordinator;
{
    @synchronized (self) {
        if (!defaultCoordinator) {
            defaultCoordinator = [[self alloc] init];
        }
        return defaultCoordinator;
    }
}

+ (id)coordinatorWithFetcherType:(FSPDataFetcherType)type;
{
    return [[self alloc] initWithFetcherType:type];
}

#pragma mark - Memory Management
- (id)init;
{
    return [self initWithFetcherType:FSPDataFetcherDefaultType];
}

- (id)initWithFetcherType:(FSPDataFetcherType)type;
{
    self = [super init];
    if (self) {
        switch (type) {
            case FSPDataFetcherNetworkType: {
                self.fetcher = [FSPNetworkClient new];
                self.liveEngineFetcher = [FSPLiveEngineClient new];
				self.profileClient = [FSPProfileClient new];
                self.managedObjectContext = FSPCoreDataManager.sharedManager.masterContext;
                break;
            }
            default: {
                [NSException raise:FSPInvalidFetcherTypeException format:@"The fetcher type (%d) is not a valid fetcher type", type];
                break;
            }
        }
    }
    return self;
}

#pragma mark - Configuration Updating
- (void)beginUpdatingConfiguration
{
    
    __block void(^callback)(BOOL success, NSDictionary *configuration) = ^(BOOL success, NSDictionary *configuration) {
        if (success) {
            NSDate *lastOrgChangeDate = [[FSPConfiguration sharedConfiguration] lastOrgChangeDate];
            NSDate *currentOrgChangeDate = [[NSUserDefaults standardUserDefaults] objectForKey:FSPLastOrgChangeDateKey];
            
            
            // First launch
            if (currentOrgChangeDate == nil) {
                currentOrgChangeDate = lastOrgChangeDate;
                [[NSUserDefaults standardUserDefaults] setObject:currentOrgChangeDate forKey:FSPLastOrgChangeDateKey];
            }
            
            if ([lastOrgChangeDate compare:currentOrgChangeDate] == NSOrderedDescending)
            {
                [[NSUserDefaults standardUserDefaults] setObject:lastOrgChangeDate forKey:FSPLastOrgChangeDateKey];
                [self updateAllOrganizationsCallback:^(BOOL success, NSDictionary *userInfo) {
                    if (success) {
                        [self updateAllTeamsForAllOrganizations:^(BOOL success) {
                            if (!success) {
                                FSPLogDataCoordination(@"Failed to update teams upon config change");
                            }
                        }];
                    }
                    else {
                        FSPLogDataCoordination(@"Failed to update organizations upon config change");
                    }
                }];
            }
            
            NSDate *lastLogoChangeDate = [[FSPConfiguration sharedConfiguration] lastLogoChangeDate];
            NSDate *currentLogoChangeDate = [[NSUserDefaults standardUserDefaults] objectForKey:FSPLastLogoChangeDateKey];
            
            // First launch
            if (currentLogoChangeDate == nil) {
                currentLogoChangeDate = lastLogoChangeDate;
                [[NSUserDefaults standardUserDefaults] setObject:currentLogoChangeDate forKey:FSPLastLogoChangeDateKey];
            }
            
            if ([lastLogoChangeDate compare:currentLogoChangeDate] == NSOrderedDescending) {
                [[NSUserDefaults standardUserDefaults] setObject:lastLogoChangeDate forKey:FSPLastLogoChangeDateKey];
                [self flushLogosForOrganizations];
            }
        }
        else {
            FSPLogDataCoordination(@"Failed to update configuration");
        }
    };
    
    
    [self.configurationProcessingQueue cancelAllOperations];
    
	[self.fetcher fetchConfiguration:^(NSDictionary *configuration) {
		
		__block BOOL operationSuccess = configuration != nil;
		
		FSPConfigurationProcessingOperation *operation = [[FSPConfigurationProcessingOperation alloc] initWithConfiguration:configuration];
		
		operation.completionBlock = ^{
			dispatch_async(dispatch_get_main_queue(), ^{
				if (callback) {
					callback(operationSuccess, configuration);
				}
				
				FSPLogDataCoordination(@"DataCoordinator finished updating configuration\n %@", configuration);

			});
		};
		
		[self.configurationProcessingQueue addOperation:operation];
	}];
}

#pragma mark - Organization Updating
- (void)updateAllOrganizationsCallback:(void (^)(BOOL success, NSDictionary *userInfo))callback;
{
    // Note: self.managedObjectContext is captured here outside the block in case it changes due to environment config change
    NSManagedObjectContext *context = self.managedObjectContext;
    
    [self.fetcher fetchOrganizationStructure:^(NSArray *organizations) {
        
        __block BOOL operationSuccess = organizations != nil;
        
        FSPOrganizationProcessingOperation *operation = [[FSPOrganizationProcessingOperation alloc] initWithOrganizations:organizations
                                                                                                                  context:context];
        operation.completionBlock = ^{
            [context performBlockAndWait:^{
                NSDictionary *userInfo;
                if (operationSuccess) {
                    userInfo = @{FSPChangedOrganizationsKey: operation.updatedObjectIDs,
                                FSPInsertedOrganizationsKey: operation.insertedObjectIDs,
                                FSPDeletedOrganizationsKey: operation.deletedObjectIDs};
                } else {
                    NSError *error = [NSError errorWithDomain:FSPDataCoordinatorErrorDomain code:102 userInfo:@{NSLocalizedDescriptionKey: @"Unable to update organizations"}];
                    userInfo = @{FSPAllOrganizationsFailedErrorKey: error};
                }
                
                if (callback) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        callback(operationSuccess, userInfo);
                    });
                }
                
                FSPLogDataCoordination(@"DataCoordinator finished updating organizations\n %@", userInfo);
                
                // Post Notifications
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *noteName = operationSuccess ? FSPAllOrganizationsUpdatedNotification : FSPAllOrganizationsFailedToUpdateNotification;
                    [[NSNotificationCenter defaultCenter] postNotificationName:noteName object:self userInfo:userInfo];
                });
            }];
        };
        
        [self.organizationProcessingQueue addOperation:operation];
        [self.organizationProcessingQueue addSaveOperation];
    }];
}

- (void)updateAllTeamsForAllOrganizations:(void (^)(BOOL success))callback;
{
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;

    [context performBlock:^{
        // Fetch all organizations that have teams and whos teams are not updated
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FSPOrganization"];
        request.predicate = [NSPredicate predicateWithFormat:@"(hasTeams == true) AND (teamsAreUpdated == false) AND (branch != %@)", @"CFB"];
        
        NSSortDescriptor *sortByOrdinal = [NSSortDescriptor sortDescriptorWithKey:@"ordinal" ascending:YES];
        [request setSortDescriptors:@[sortByOrdinal]];
        
        NSArray *orgsNeedingUpdate = [context executeFetchRequest:request error:nil];
        
        
        NSArray *cfb = nil;
        if (orgsNeedingUpdate.count) {
            NSFetchRequest *requestA = [NSFetchRequest fetchRequestWithEntityName:@"FSPOrganization"];
            requestA.predicate = [NSPredicate predicateWithFormat:@"(hasTeams == false) AND (branch == %@) AND (type == %@) AND (teamsAreUpdated == false)", @"CFB", @"SPORT"];
            cfb = [context executeFetchRequest:requestA error:nil];
            FSPOrganization *cfbOrg = (FSPOrganization *)[cfb lastObject];
            NSLog(@"update rankings on CFB: %@", cfbOrg.name);
            [cfbOrg updateRankings];
        }
        
        NSMutableArray *orgsToUpdate = [NSMutableArray arrayWithArray:orgsNeedingUpdate];
        [orgsToUpdate addObjectsFromArray:cfb];
        
        FSPLogDataCoordination(@"updating orgs %@", [orgsToUpdate valueForKeyPath:@"name"]);
        
        FSPManagedObjectCache *teamsCache = [FSPManagedObjectCache cacheForEntityName:NSStringFromClass(FSPTeam.class)
                                                                            inContext:context];
        
        for (FSPOrganization *org in orgsToUpdate) {
            NSManagedObjectID *orgID = org.objectID;
            
            [fetcher fetchTeamsForOrganizationId:org.objectID callback:^(NSArray *teams) {
                
                FSPTeamProcessingOperation *operation = [[FSPTeamProcessingOperation alloc] initWithContext:context
                                                                                                  teamCache:teamsCache];
                BOOL operationSuccess = (teams.count > 0);
                
                operation.completionBlock = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *notificationName = operationSuccess ? FSPDataCoordinatorDidUpdateTeamsForOrganizationNotification : FSPDataCoordinatorFailedToUpdateTeamsForOrganizationNotification;
                        
                        // Post notification
                        NSNotification *note = [NSNotification notificationWithName:notificationName object:self userInfo:@{FSPDataCoordinatorUpdatedOrganizationObjectIDKey: orgID}];
                        [[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:NSPostASAP coalesceMask:NSNotificationNoCoalescing forModes:nil];
                    });
                };
                
                operation.organizationId = org.objectID;
                operation.teams = teams;
                [self.organizationProcessingQueue addOperation:operation];
                //[self.organizationProcessingQueue addOperation:[[FSPChipTeamsProcessingOperation alloc] initWithContext:self.managedObjectContext]];
                [self.organizationProcessingQueue addSaveOperationWithCallback:^(BOOL saveSucceeded) {
                    if (saveSucceeded) {
                        [context performBlock:^{
                            BOOL processingSucceeded = [context countForFetchRequest:request error:nil] == 0;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (callback)
                                    callback(processingSucceeded);
                            });
                        }];
                    }
                }];
            }];
        }
    }];
}

- (void)flushLogosForOrganizations
{
    FSPLogDataCoordination(@"refreshing organization logos");
    
    NSManagedObjectContext *context = self.managedObjectContext;
    [context performBlock:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FSPOrganization"];
        NSArray *orgsWithLogos = [context executeFetchRequest:request error:nil];
        
        for (FSPOrganization *organization in orgsWithLogos) {
            [FSPImageFetcher.sharedFetcher invalidateURL:[NSURL URLWithString:organization.logo1URL]];
            [FSPImageFetcher.sharedFetcher invalidateURL:[NSURL URLWithString:organization.logo2URL]];
        }
        
        [FSPCoreDataManager.sharedManager synchronizeSavingWithCallback:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:FSPAllOrganizationsUpdatedNotification object:nil userInfo:nil];
        }];
    }];

}

#pragma mark - Flush Methods
- (void)flushAllOrganizationCallback:(void (^)(BOOL success, NSArray *deletedOrganizationIds))callback;
{
    NSManagedObjectContext *context = self.managedObjectContext;
    [context performBlock:^{
        NSFetchRequest *allOrgsRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPOrganization"];
        NSArray *allOrgs = [context executeFetchRequest:allOrgsRequest error:nil];
        
        NSMutableArray *deletedOrgIDs = [NSMutableArray arrayWithCapacity:[allOrgs count]];
        
        for (FSPOrganization *org in allOrgs) {
            if (org.schedule)
                [context deleteObject:org.schedule];
            [context deleteObject:org];
            [deletedOrgIDs addObject:[org objectID]];
        }
        
        [context processPendingChanges];
        
        BOOL success = [context save:nil];
        [[FSPCoreDataManager sharedManager] synchronizeSavingWithCallback:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    NSArray *deletedOrgs = [deletedOrgIDs copy];
                    [[NSNotificationCenter defaultCenter] postNotificationName:FSPAllOrganizationsUpdatedNotification object:nil userInfo:@{FSPDeletedOrganizationsKey: deletedOrgs}];

                    if (callback) {
                        callback(YES, deletedOrgs);
                    }
                } else {
                    NSError *error = [NSError errorWithDomain:FSPDataCoordinatorErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey: @"Unable to save managed object context"}];
                    [[NSNotificationCenter defaultCenter] postNotificationName:FSPAllOrganizationsFailedToUpdateNotification object:nil userInfo:@{FSPAllOrganizationsFailedErrorKey: error}];

                    if (callback) {
                        callback(NO, nil);
                    }
                }
            });
        }];
    }];
}

#pragma mark - Mass Relevance Management

- (void)updateMassRelevanceForOrganizationId:(NSManagedObjectID *)organizationId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
{
    if (!organizationId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success)
                success(nil);
        });
    }
    
    [self.fetcher fetchMassRelevanceForOrganizationId:organizationId success:^(NSArray *tweets) {
        
        
        success(tweets);
//        FSPScheduleProcessingOperation *operation = [[FSPScheduleProcessingOperation alloc] initWithSchedule:schedule forOrganizationId:organizationId];
//        operation.completionBlock = ^{
//            if (success) {
//                success(operation.sortedScheduleArray);
//            }
//        };
//        [self.scheduleProcessingQueue addOperation:operation];
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - Schedule Management
- (void)updateScheduleForOrganizationId:(NSManagedObjectID *)organizationId;
{
    [self updateScheduleForOrganizationId:organizationId success:nil failure:nil];
}

- (void)updateScheduleForOrganizationId:(NSManagedObjectID *)organizationId success:(void (^)(NSArray *))callback;
{
    [self updateScheduleForOrganizationId:organizationId success:callback failure:nil];
}

- (void)updateScheduleForOrganizationId:(NSManagedObjectID *)organizationId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
{
    if (!organizationId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success)
                success(nil);
        });
    }
    
    NSManagedObjectContext *context = self.managedObjectContext;

    [self.fetcher fetchScheduleForOrganizationId:organizationId success:^(NSArray *schedule) {
        FSPScheduleProcessingOperation *operation = [[FSPScheduleProcessingOperation alloc] initWithSchedule:schedule
                                                                                           forOrganizationId:organizationId
                                                                                               context:context];
        operation.completionBlock = ^{
            if (success) {
                success(operation.sortedScheduleArray);
            }
        };
        [self.scheduleProcessingQueue addOperation:operation];
        [self.scheduleProcessingQueue addSaveOperation];
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - Standings
- (void)updateStandingsForOrganizationId:(NSManagedObjectID *)organizationId callback:(void (^)(BOOL success))callback;
{    
    if (!organizationId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
                callback(NO);
        });
        return;
    }

    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;
    FSPDataCoordinator *coordinator = [FSPDataCoordinator defaultCoordinator];

    [context performBlock:^{
        FSPOrganization *org = (FSPOrganization *)[context existingObjectWithID:organizationId error:nil];
        if (!org)
            return;

        if ([org.branch isEqualToString:FSPUFCEventBranchType]) {
            [coordinator updateTitleHoldersForOrganizationId:organizationId callback:callback];
            
            return;
        }
        
        [fetcher fetchStandingsForOrganizationId:organizationId callback:^(NSArray *standings) {
            
            __block BOOL operationSuccess = (standings != nil);
            
            FSPStandingsProcessingOperation *operation;
            if ([org.baseBranch isEqualToString:FSPNASCAREventBranchType]) {
                operation = [[FSPRacingStandingsProcessingOperation alloc] initWithStandings:standings
                                                                                      branch:org.branch
                                                                                     context:context];
            } else if ([org.baseBranch isEqualToString:FSPGolfBranchType]) {
                operation = [[FSPGolfStandingsProcessingOperation alloc] initWithStandings:standings
                                                                                    branch:org.branch
                                                                                   context:context];
            } else if ([org.baseBranch isEqualToString:FSPTennisEventBranchType]){
                operation = [[FSPTennisStandingsProcessingOperation alloc] initWithStandings:standings
                                                                                      branch:org.branch
                                                                                     context:context];
            } else {
                operation = [[FSPStandingsProcessingOperation alloc] initWithStandings:standings
                                                                               context:context];
            }
            
            [self.standingsProcessingQueue addOperation:operation];
            [self.standingsProcessingQueue addSaveOperationWithCallback:^(BOOL success) {
                if (operationSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(operationSuccess);
                        }
                    });
                    FSPLogDataCoordination(@"Updated standings for organization %@: \n\n %@", organizationId, standings);
                }
            }];
        }];
    }];
}

- (void)updateStandingsForOrganizationIds:(NSArray *)organizationIds callback:(void (^)(BOOL success))callback;
{
	// TODO: impl.
	// the standings call "should" take sport/branch orgs (that contain teams) rather than individual teams, so handle that here?
}

- (void)updateTitleHoldersForOrganizationId:(NSManagedObjectID *)orgId callback:(void (^)(BOOL success))callback
{
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;

    [context performBlock:^{
        [fetcher fetchUFCTitleholdersForOrgId:orgId callback:^(NSArray *titleHolders) {
            FSPTitleHolderProcessingOperation *operation = [[FSPTitleHolderProcessingOperation alloc] initWithOrgId:orgId
                                                                                                   titleHoldersData:titleHolders
                                                                                                            context:context];
            operation.completionBlock = ^{
                __block BOOL operationSuccess = (titleHolders != nil);
                
                if (operationSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(operationSuccess);
                        }
                    });
                }
            };
            [self.standingsProcessingQueue addOperation:operation];
            [self.standingsProcessingQueue addSaveOperation];
        }];
    }];
}

- (void)updateRacingStandindsForOrganizationId:(NSManagedObjectID *)orgId
{
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;

    [context performBlock:^{
        [fetcher fetchUFCTitleholdersForOrgId:orgId callback:^(NSArray *titleHolders) {
            FSPTitleHolderProcessingOperation *operation = [[FSPTitleHolderProcessingOperation alloc] initWithOrgId:orgId
                                                                                                   titleHoldersData:titleHolders
                                                                                                            context:context];
			
            [self.standingsProcessingQueue addOperation:operation];
            [self.standingsProcessingQueue addSaveOperation];
        }];
    }];
}

- (void)updateRankingsForOrganizationId:(NSManagedObjectID *)orgId callback:(void (^)(BOOL success))callback
{
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;
    
    [context performBlock:^{
        [fetcher fetchRankingsForOrganization:orgId callback:^(NSDictionary *rankingsData) {
            FSPRankingsProcessingOperation *operation = [[FSPRankingsProcessingOperation alloc] initWithRankings:rankingsData
                                                                                                           orgId:orgId
                                                                                                         context:context];
            __block BOOL operationSuccess = (rankingsData != nil);
                

            [self.standingsProcessingQueue addOperation:operation];
            [self.standingsProcessingQueue addSaveOperationWithCallback:^(BOOL success) {
                if (operationSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(operationSuccess);
                        }
                    });
                }
            }];
            
        }];
    }];
}

#pragma mark - Chip Updating

- (void)beginUpdatingEventsForOrganizationId:(NSManagedObjectID *)organizationId
{
	[self beginUpdatingEventsForOrganizationIds:@[organizationId]];
}

- (void)beginUpdatingEventsForOrganizationIds:(NSArray *)organizationIds
{
	if ([organizationIds isEqualToArray:self.currentPollingOrganizations]) {
		// we're already polling for this set of organizations
		return;
	}
	self.currentPollingOrganizations = organizationIds;
	
	FSPLogDataCoordination(@"BEGINNING TO UPDATE %@", organizationIds);
    static NSTimeInterval chipUpdateInterval = 30;
    static NSTimeInterval chipLiveEngineUpdateInterval = 5;
    if (organizationIds == nil || organizationIds.count == 0) {
        return;
    }
    
    [self endUpdatingEventsForCurrentOrganizations];
    
    [self updateChipFeedForOrganizationIds:organizationIds WithTimeInterval:chipUpdateInterval];
	if (organizationIds.count == 1) {
		[self updateLiveEngineChipFeedForOrganizationId:[organizationIds lastObject] WithTimeInterval:chipLiveEngineUpdateInterval];
	}
}

- (void)updateChipFeedForOrganizationIds:(NSArray *)organizationIds WithTimeInterval:(NSTimeInterval)timeInterval
{
    __block BOOL updateAffiliateAndStreamability = YES;
    __weak FSPDataCoordinator *weakSelf = self;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;

    NSManagedObjectContext *context = self.managedObjectContext;
    
#ifdef DEBUG
    //NSLog(@"begin updating orgs: %@", organizationIds);
    NSMutableArray *orgNames = NSMutableArray.new;
    for (id orgId in organizationIds) {
        [orgNames addObject:[[context objectWithID:orgId] valueForKey:@"name"]];
    }
    
    __block NSDate *startTime = [NSDate date];
#endif
    
    
    [[FSPPollingCenter defaultCenter] addPollingActionForKey:FSPChipsPollingActionKey timeInterval:timeInterval usingBlock:^{
        
        // pull updated list of events based on org id
        [fetcher fetchEventsForOrganizationIds:organizationIds callback:^(NSArray *events) {
            
            
#ifdef DEBUG
            NSLog(@"end chip feed for orgs: %@   >>>>> (%fms)", [orgNames componentsJoinedByString:@","], ABS([startTime timeIntervalSinceNow]));
            startTime = [NSDate date];
#endif
            // https://ubermind.jira.com/browse/FSTOGOIOS-2045. Notify listeners that no event data was returned.
            if (events.count == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:FSPDataCoordinatorNoEventDataFoundNotification object:nil];
            }
            // process events on event queue
            FSPEventsProcessingOperation *processingOperation = [[FSPEventsProcessingOperation alloc] initWithEvents:events
                                                                                                               batch:(organizationIds.count > 1)
                                                                                                        organizationIds:organizationIds
                                                                                                             context:context];
            processingOperation.completionBlock = ^ {
                [context performBlockAndWait:^{
                    // Fetch all organizations that have teams and whos teams are not updated
                    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FSPEvent"];
                    request.predicate = [NSPredicate predicateWithFormat:@"(eventStarted == true) AND (eventCompleted == false) AND (gameDictionaryCreated == false)"];
                    
                    NSArray *allEventsNeedingGameDictionaries = [context executeFetchRequest:request error:nil];
                    
                    // TODO: make this work for multiple orgs
                    if (organizationIds.count == 1) {
                        FSPOrganization *organization = (FSPOrganization *)[context existingObjectWithID:[organizationIds lastObject] error:nil];
                        if (organization)
                            return;
                        
                        NSString *currentSelectedEventID = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@%@", FSPSelectedEventUserDefaultsPrefixKey, organization.branch]];
                        for (FSPEvent *event in allEventsNeedingGameDictionaries) {
                            
                            // We need to make sure we aren't updating the current event because that is done elsewhere.
                            if (event.uniqueIdentifier && ![event.uniqueIdentifier isEqualToString:currentSelectedEventID]) {
                                [self updateLiveEngineGameDictionaryForEvent:event.objectID update:NO];
                            }
                        }
                    }
                    
                    FSPLogDataCoordination(@"Events downloaded %@", events);
                }];
            };
            
			// only update affiliate and streamability afer first poll
			if (updateAffiliateAndStreamability && ([events count] > 0))
			{
				[weakSelf updateStreamabilityForEvents:events];
				[weakSelf updateTelevisionAffiliateForEventIds:events organizationIds:organizationIds];
				updateAffiliateAndStreamability = NO;
			}
            
            [weakSelf.chipProcessingQueue addOperation:processingOperation];
            [weakSelf.chipProcessingQueue addOperation:[[FSPChipTeamsProcessingOperation alloc] initWithContext:self.managedObjectContext]]; // we're doing this processing as we iterate over the newly added events
            [weakSelf.chipProcessingQueue addSaveOperationWithCallback:^(BOOL success) {
                if (success) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FSPDataCoordinatorDidUpdateTeamsForOrganizationNotification
                                                                        object:nil
                                                                      userInfo:nil];
                }
            }];
        }];

    }];
}

- (void)updateLiveEngineChipFeedForOrganizationId:(NSManagedObjectID *)organizationId WithTimeInterval:(NSTimeInterval)timeInterval;
{
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPLiveEngineDataRetrieving> liveEngineFetcher = self.liveEngineFetcher;
    [context performBlock:^{
        //TODO: Remove when live engine data is not null for Soccer
        FSPOrganization *organization = (FSPOrganization *)[context existingObjectWithID:organizationId error:nil];
        if (organization && organization.viewType == FSPSoccerViewType) {
            return;
        }
        
        __weak FSPDataCoordinator *weakSelf = self;
        [[FSPPollingCenter defaultCenter] addPollingActionForKey:FSPLiveEngineChipsPollingActionKey timeInterval:timeInterval usingBlock:^{
            
            [liveEngineFetcher fetchLiveEngineChipsForOrganizationId:organizationId success:^(NSDictionary *events) {
                if (events) {
                    NSArray *chips = [[events objectForKey:@"data"] objectForKey:@"AGS"];
                    
                    //process live engine chips
                    FSPLiveEngineChipProcessingOperation *processingOperation = [[FSPLiveEngineChipProcessingOperation alloc] initWithEvents:chips
                                                                                                                                     context:context];
                    processingOperation.completionBlock = ^{
                        FSPLogDataCoordination(@"Live Engine Events downloaded %@", chips);
                    };
                    [weakSelf.chipProcessingQueue addOperation:processingOperation];
                    [weakSelf.chipProcessingQueue addSaveOperation];
                }
            } failure:^(NSError *error) {
				[[FSPPollingCenter defaultCenter] stopPollingActionForKey:FSPLiveEngineChipsPollingActionKey];
                NSLog(@"Error updating live chips:%@", error);
            }];
        }];
    }];
}

- (void)endUpdatingEventsForCurrentOrganizations;
{
    [self.chipProcessingQueue cancelAllOperations];
    
	[[FSPPollingCenter defaultCenter] stopPollingActionForKey:FSPChipsPollingActionKey];
	[[FSPPollingCenter defaultCenter] stopPollingActionForKey:FSPLiveEngineChipsPollingActionKey];
}

- (void)updateStreamabilityForEvents:(NSArray *)eventIds
{
    if (!eventIds || eventIds.count == 0) return;
    
    NSManagedObjectContext *context = self.managedObjectContext;

    [self.fetcher fetchStreamabilityForEventIds:eventIds callback:^(NSDictionary *streamabilityInfo) {
        
        FSPEventStreamabilityProcessingOperation *processingOperation = [[FSPEventStreamabilityProcessingOperation alloc] initWithStreamabilityInfo:streamabilityInfo
                                                                                                                                             events:eventIds
                                                                                                                                            context:context];
        processingOperation.completionBlock = ^{
        };
        
        [self.chipProcessingQueue addOperation:processingOperation];
        [self.chipProcessingQueue addSaveOperation];
    }];
}

- (void)updateTelevisionAffiliateForEventIds:(NSArray *)eventIds organizationIds:(NSArray *)organizationIds
{
    if (!eventIds || eventIds.count == 0) return;
    
    NSManagedObjectContext *context = self.managedObjectContext;

    [self.fetcher fetchAffiliatesForEventIds:eventIds callback:^(NSDictionary *affiliateInfo) {
        
        FSPEventAffiliateIdentificationProcessingOperation *processingOperation = [[FSPEventAffiliateIdentificationProcessingOperation alloc] initWithAffiliateInfo:affiliateInfo
                                                                                                                                                    organizationIds:organizationIds
                                                                                                                                                            context:context];
        processingOperation.completionBlock = ^{
        };
        
        [self.chipProcessingQueue addOperation:processingOperation];
        [self.chipProcessingQueue addSaveOperation];
    }];
}

#pragma mark - News

- (void)updateNewsCities:(void (^)(void))success failure:(void (^)(NSError *error))failure
{
    NSManagedObjectContext *context = self.managedObjectContext;

    [self.fetcher fetchNewsCities:^(NSDictionary *newsCities) {
        FSPLogDataCoordination(@"updating top news cities with response %@", newsCities);
        FSPNewsCityProcessingOperation *operation = [[FSPNewsCityProcessingOperation alloc] initWithNewsCities:newsCities
                                                                                                       context:context];
        operation.completionBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success)
                    success();
            });
        };
        [self.newsProcessingQueue addOperation:operation];
        [self.newsProcessingQueue addSaveOperation];
    } failure:failure];
}

- (void)updateTopNewsHeadlines:(void (^)(void))success failure:(void (^)(NSError *error))failure;
{
    NSManagedObjectContext *context = self.managedObjectContext;

    [self.fetcher fetchTopNewsHeadlines:^(NSArray *headlines) {
        FSPLogDataCoordination(@"updating top news headlines with response %@", headlines);
        FSPNewsProcessingOperation *operation = [[FSPNewsProcessingOperation alloc] initWithTopNewsHeadlines:headlines
                                                                                                     context:context];
        operation.completionBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success)
                    success();
            });
        };
        [self.newsProcessingQueue addOperation:operation];
        [self.newsProcessingQueue addSaveOperation];
    } failure:^(NSError *error) {
        FSPLogDataCoordination(@"Failed to update top news - %@", error);
        if (failure)
            failure(error);
    }];
}

- (void)updateNewsHeadlinesForCity:(NSManagedObjectID *)cityId success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
{
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;

    [context performBlock:^{
        __block void(^fetchSuccess)(NSArray *headlines) = ^(NSArray *headlines) {
            FSPLogDataCoordination(@"updating local news headlines with response %@", headlines);
            FSPNewsProcessingOperation *operation = [[FSPNewsProcessingOperation alloc] initWithLocalNewsHeadlines:headlines
                                                                                                        newsCityId:cityId
                                                                                                           context:context];
            operation.completionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success)
                        success();
                });
            };
            [self.newsProcessingQueue addOperation:operation];
            [self.newsProcessingQueue addSaveOperation];
        };
        
        __block void(^fetchFailure)(NSError *error) = ^(NSError *error) {
            FSPLogDataCoordination(@"Failed to update top news - %@", error);
            if (failure)
                failure(error);
        };
        
        FSPNewsCity *city = (FSPNewsCity *)[context existingObjectWithID:cityId error:nil];
        if (city) {
            if (city.cityId) {
                [fetcher fetchLocalNewsHeadlinesForCityId:city.cityId success:fetchSuccess failure:fetchFailure];
            } else {
                [fetcher fetchLocalNewsHeadlinesForAffiliateId:city.affiliateId success:fetchSuccess failure:fetchFailure];
            }
        }
    }];
}

- (void)updateNewsHeadlinesForOrganizationId:(NSManagedObjectID *)organizationId success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
{    
    NSManagedObjectContext *context = self.managedObjectContext;

    [self.fetcher fetchRelatedNewsHeadlinesForOrganizationId:organizationId success:^(NSArray *headlines) {
        FSPLogDataCoordination(@"Updating related news headlines for organization (%@) with response %@", organizationId, headlines);
        FSPNewsProcessingOperation *operation = [[FSPNewsProcessingOperation alloc] initWithNewsHeadlines:headlines
                                                                                           organizationId:organizationId
                                                                                                  context:context];
        operation.completionBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success)
                    success();
            });
        };
        [self.newsProcessingQueue addOperation:operation];
        [self.newsProcessingQueue addSaveOperation];
    } failure:^(NSError *error) {
        FSPLogDataCoordination(@"Failed to update top news - %@", error);
        if (failure)
            failure(error);
    }];    
}

- (void)asynchronouslyLoadNewsStoryForHeadline:(NSManagedObjectID *)headlineId success:(void (^)(FSPNewsStory *newsObjectId))success failure:(void (^)(NSError *error))failure;
{
#ifdef DEBUG
    NSParameterAssert(headlineId);
#endif

    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;

    [context performBlock:^{
        FSPNewsHeadline *headline = (FSPNewsHeadline *)[context existingObjectWithID:headlineId error:nil];
        if (!headline)
            return;
#ifdef DEBUG
        NSParameterAssert([headline isKindOfClass:FSPNewsHeadline.class]);
#endif
        
        // Try getting the story from on disk
        FSPNewsStory *storyFromDisk = [FSPNewsStory newsStoryWithContentsOfFile:[headline newsStoryPath]];
        if (storyFromDisk.isExpired) {
            storyFromDisk = nil;
            [[NSFileManager defaultManager] removeItemAtURL:[headline newsStoryPath] error:nil];
        }
        
        if (storyFromDisk) {
            storyFromDisk.backingFile = [headline newsStoryPath];
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(storyFromDisk);
                });
            }
        } else {
            // We need to load if from the network
            [fetcher fetchNewsStoryWithIdentifier:headline.newsId success:^(NSDictionary *storyObject) {
                [context performBlock:^{
                    if (storyObject) {
                        FSPNewsStory *storyFromNetwork = [FSPNewsStory newsStoryFromDictionary:storyObject];
                        storyFromNetwork.backingFile = [headline newsStoryPath];
                        if (success) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                success(storyFromNetwork);
                            });
                        }
                    }
                }];
            } failure:^(NSError *error) {
                if (failure) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failure(error);
                    });
                }
            }];
        }
    }];
}

- (void)asynchronouslyLoadNewsStoryForEvent:(NSManagedObjectID *)eventId storyType:(FSPStoryType)storyType success:(void (^)(FSPNewsStory *newsObjectId))success failure:(void (^)(NSError *error))failure;
{
#ifdef DEBUG
    NSParameterAssert(eventId);
#endif
    
    NSManagedObjectContext *context = self.managedObjectContext;
    id <FSPDataCoordinatorDataRetrieving> fetcher = self.fetcher;
    
    [context performBlock:^{
        FSPEvent *event = (FSPEvent *)[context existingObjectWithID:eventId error:nil];
        if (!event)
            return;
#ifdef DEBUG
        NSParameterAssert([event isKindOfClass:FSPEvent.class]);
#endif

        [fetcher fetchStoryForEventId:eventId storyType:storyType
                              success:^(NSDictionary *storyObject) {
                                  if (storyObject) {
                                      FSPNewsStory *storyFromNetwork = [FSPNewsStory newsStoryFromDictionary:storyObject];
                                      if (success) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              success(storyFromNetwork);
                                          });
                                      }
                                  }
                              }
                              failure:^(NSError *error) {
                                  if (failure) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          failure(error);
                                      });
                                  }
                              }];
    }];
}

#pragma mark-
- (void)updateLeaderboardForEventIdentifier:(NSString *)eventIdentifier callback:(void (^)(BOOL success))callback;
{
    //    [[self fetcherForSelector:@selector(fetchLeaderboardForEventWithIdentifier:callback:)] fetchLeaderboardForEventWithIdentifier:eventIdentifier callback:^(NSArray *leaders) {
    //        
    //        // TODO: remove.. only do once for now
    //        static dispatch_once_t onceToken;
    //        dispatch_once(&onceToken, ^{
    //            for (NSDictionary *playerInfo in leaders) {
    //                FSPGolfer *golfer = [NSEntityDescription insertNewObjectForEntityForName:@"FSPGolfer" inManagedObjectContext:self.managedObjectContext];
    //                golfer.eventId = eventIdentifier;
    //                golfer.firstName = [playerInfo objectForKey:@"firstName"];
    //                golfer.lastName = [playerInfo objectForKey:@"lastName"];
    //                golfer.position = [playerInfo objectForKey:@"position"];
    //                golfer.score = [playerInfo objectForKey:@"score"];
    //                golfer.thru = [playerInfo objectForKey:@"thru"];
    //                golfer.today = [playerInfo objectForKey:@"today"];
    //                golfer.round1 = [playerInfo objectForKey:@"round1"];
    //                golfer.round2 = [playerInfo objectForKey:@"round2"];
    //                golfer.round3 = [playerInfo objectForKey:@"round3"];
    //                golfer.round4 = [playerInfo objectForKey:@"round4"];
    //                golfer.strokes = [playerInfo objectForKey:@"strokes"];
    //                
    //            }
    //            
    //            [self.managedObjectContext save:nil];
    //        });
    //        
    //        
    //        
    //        if (callback) {
    //            callback(YES);
    //        } 
    //    }];
}

- (void)updateVideosForOrganizationsIds:(NSArray *)organizations callback:(void (^)(BOOL success))callback;
{
    NSManagedObjectContext *context = self.managedObjectContext;

	[self.fetcher fetchVideosForOrganizationIds:organizations callback:^(NSDictionary *videos) {
        FSPVideoProcessingOperation *processingOperation = [[FSPVideoProcessingOperation alloc] initWithVideos:videos
                                                                                                     forOrgIDs:organizations
                                                                                                       context:context];
        __block BOOL operationSuccess = (videos != nil);
        processingOperation.completionBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(callback)
                    callback(operationSuccess);
            });
        };
        
        [self.eventProcessingQueue addOperation:processingOperation];
        [self.eventProcessingQueue addSaveOperation];
	}];
}

- (void)updateVideosForEventId:(NSManagedObjectID *)eventID callback:(void (^)(BOOL success))callback;
{
    NSManagedObjectContext *context = self.managedObjectContext;

	[self.fetcher fetchVideosForEventId:eventID callback:^(NSDictionary *videos) {
        FSPVideoProcessingOperation *processingOperation = [[FSPVideoProcessingOperation alloc] initWithVideos:videos
                                                                                                    forEventID:eventID
                                                                                                       context:context];
        __block BOOL operationSuccess = (videos != nil);
        processingOperation.completionBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(callback)
                    callback(operationSuccess);
            });
        };
        
        [self.eventProcessingQueue addOperation:processingOperation];
        [self.eventProcessingQueue addSaveOperation];
	}];
}

- (void)getPlatformAuthenticationTokenWithCallback:(void (^)(NSString *token))callback
{
    [self.fetcher fetchVideoAuthenticationTokenWithCallback:callback];
}

@end
