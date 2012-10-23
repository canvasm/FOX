//
//  FSPLiveEngineClient.m
//  FoxSports
//
//  Created by Jason Whitford on 4/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPLiveEngineClient.h"
#import "FSPOrganization.h"
#import "FSPEvent.h"
#import "AFJSONRequestOperation.h"
#import "FSPCoreDataManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "FSPAppDelegate.h"
#import "FSPSettingsBundleHelper.h"

@interface FSPLiveEngineClient()
- (NSString *)pathCreationWithEvent:(FSPEvent *)event liveEngineIdentifier:(NSNumber *)liveEngineIdentifier;

@end

@implementation FSPLiveEngineClient

- (NSURL *)currentBaseURL {
    if ([[FSPSettingsBundleHelper liveDataURL] isEqualToString:FSPSettingsBundleLiveDataURLGameDictionary]) {
        return nil;
    }
    else {
        return [NSURL URLWithString:[FSPSettingsBundleHelper liveDataURL]];
    }
}

- (id)init
{
    self = [super initWithBaseURL:[self currentBaseURL]];
    if (self) {
        self.parameterEncoding = AFJSONParameterEncoding;
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    return self;
}

- (void)fetchLiveEngineChipsForOrganizationId:(NSManagedObjectID *)orgId success:(void (^)(NSDictionary *events))success failure:(void (^)(NSError *error))failure;
{
    NSManagedObjectContext *context = self.managedObjectContext;
    [context performBlock:^{
        FSPOrganization *org = (id)[context existingObjectWithID:orgId error:nil];
        if (!org)
            return;
        NSString *path = [NSString stringWithFormat:@"?branch=%@&type=lgb", org.branch];
        
        if ([[FSPSettingsBundleHelper liveDataURL] isEqualToString:FSPSettingsBundleLiveDataURLGameDictionary]) {
            // See commentary below in pathCreationWithEvent:. Note that this logic will break for the "all sports" league bundle;
            // revisit this code. TODO: get one live engine URL per view type. For now just use the first event, if available, and
            // bail out otherwise
            BOOL haveURL = NO;
            for (FSPEvent *event in org.events) {
                if (event.liveDataURL) {
                    path = [event.liveDataURL stringByAppendingString:path];
                    haveURL = YES;
                    break;
                }
            }
            if (!haveURL) {
                // No events to get live engine base URL from - can't get league bundle at this timee
                return;
            }
        }

        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = NO;
        [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *op, id response) {
            if (success && [response isKindOfClass:[NSDictionary class]])
                success(response);
            [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        } failure:^(AFHTTPRequestOperation *op, NSError *error) {
            if (failure)
                failure(error);
        }];
    }];
}

- (void)fetchMessageBundleForEventId:(NSManagedObjectID *)eventId liveEngineIdentifier:(NSNumber *)liveEngineIdentifier success:(void (^)(NSDictionary *messageBundle))success failure:(void (^)(NSError *error))failure;
{
    NSManagedObjectContext *context = self.managedObjectContext;
    [context performBlock:^{
        FSPEvent *event = (FSPEvent *)[context existingObjectWithID:eventId error:nil];
        if (event) {
            NSString *path = [self pathCreationWithEvent:event liveEngineIdentifier:liveEngineIdentifier];
            [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *op, id response) {
                if (success && [response isKindOfClass:[NSDictionary class]])
                    success(response);
            } failure:^(AFHTTPRequestOperation *op, NSError *error) {
                if (failure)
                    failure(error);
            }];
        } else {
            FSPLogFetching(@"Couldn't find event for %@ fetching message bundle", eventId);
        }
    }];
}

- (NSString *)pathCreationWithEvent:(FSPEvent *)event liveEngineIdentifier:(NSNumber *)liveEngineIdentifier
{
    NSString *path;
    if ([[FSPSettingsBundleHelper dataScheme] isEqualToString:FSPSettingsBundleLiveDataURLSchemeNugget]) {
        //When this is set, it is forced to used the game dictionary URL
        path = [NSString stringWithFormat:@"%@/%@/EVENT", liveEngineIdentifier, event.branch];
        path = [event.liveDataURL stringByAppendingString:path];
    } else {
        int currentVersion = event.liveEngineUpdatedVersion.intValue;
        
        //    //Test Deltas
        //    if (currentVersion == FSPLiveEngineDefault)
        //        currentVersion = 0;
        
        path = [NSString stringWithFormat:@"?branch=%@&eventNativeID=%@", event.branch, liveEngineIdentifier];
        
        if ([[FSPSettingsBundleHelper liveDataURL] isEqualToString:FSPSettingsBundleLiveDataURLGameDictionary]) {
            // Though it may seem like this shouldn't work, it does because [self requestWithMethod:@"GET" path:path parameters:parameters], which uses the results of this
            // method for its path parameter, calls [AFHTTPClient requestWithMethod:@"GET" path:path parameters:parameters]
            // This then does the Right Thing:
            // https://github.com/AFNetworking/AFNetworking/issues/100
            path = [event.liveDataURL stringByAppendingString:path];
        }
        
        if (currentVersion == FSPLiveEngineDefault || [event.eventState isEqualToString:@"FINAL"])
            path = [path stringByAppendingString:[NSString stringWithFormat:@"&type=init"]];
        else
            path = [path stringByAppendingString:[NSString stringWithFormat:@"&type=game&version=%d", currentVersion+1]];
        
    } 
    return path;
}


@end
