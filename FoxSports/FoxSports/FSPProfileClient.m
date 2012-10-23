//
//  FSPProfileClient.m
//  FoxSports
//
//  Created by greay on 5/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPProfileClient.h"
#import "FSPLiveEngineClient.h"
#import "FSPEvent.h"
#import "AFJSONRequestOperation.h"
#import "UAirship.h"
#import "FSPCoreDataManager.h"
#import "FSPAppDelegate.h"
#import "FSPSettingsBundleHelper.h"

@implementation FSPProfileClient

- (NSURL *)currentBaseURL {
	// 	return [NSURL URLWithString:@"http://qa-data.foxsports.com"];
	return [NSURL URLWithString:[FSPSettingsBundleHelper appEnvironmentURL]];
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


- (void)createProfile:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure
{
#if (defined(FSP_ENABLE_ALERTS) && !TARGET_IPHONE_SIMULATOR)

	NSString *path = [NSString stringWithFormat:@"/profile"];
	NSDictionary *profile = [NSDictionary dictionaryWithObjectsAndKeys:@"IOS", @"profileType",
							 [[UIDevice currentDevice] name], @"profileName",
							 [[UAirship shared] deviceToken], @"clientId",
							 nil];
	
    [self postPath:path parameters:profile success:^(AFHTTPRequestOperation *op, id response) {
        if (success && [response isKindOfClass:[NSDictionary class]]) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			NSNumber *profileId = [response valueForKey:@"profileId"];
			[defaults setValue:profileId forKey:@"profileId"];
			[defaults synchronize];
			
			// 100000000000000303
            success(response);
		}
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        if (failure) {
            failure(error);
		}
    }];
#else
	NSError *error = [NSError errorWithDomain:@"FSPNotificationsErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Alerts are disabled"}];
	failure(error);
#endif
}

- (void)subscribeToAlertForEvent:(NSManagedObjectID *)eventId preferences:(NSDictionary *)prefs success:(void (^)())success failure:(void (^)(NSError *error))failure
{
	/*
	 startAlert,
	 finishAlert,
	 phaseBasedAlert,
	 scoreBasedAlert,
	 
	 */
	NSManagedObjectContext *context = [FSPCoreDataManager.sharedManager GUIObjectContext];
	FSPEvent *event = (FSPEvent *)[context existingObjectWithID:eventId error:nil];
    if (!event)
        return;
	
    NSString *path = [NSString stringWithFormat:@"/subscription"];
	NSDictionary *subscription = @{@"fsId": event.uniqueIdentifier,
								  @"branch": event.branch,
								  @"itemType": event.itemType,
								  @"alerts": prefs};
	NSMutableArray *subscriptions = [NSMutableArray arrayWithObject:subscription];
	NSArray *allSubs = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"];
	for (NSDictionary *sub in allSubs) {
		if (![[sub valueForKey:@"fsId"] isEqualToString:event.uniqueIdentifier]) {
			[subscriptions addObject:sub];
		}
	}

	NSDictionary *params = @{@"profileId": [[NSUserDefaults standardUserDefaults] valueForKey:@"profileId"],
							@"subscriptions": subscriptions};
	
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *op, id response) {
        if (success) {
			[[NSUserDefaults standardUserDefaults] setObject:subscriptions forKey:@"subscriptions"];
            success();
		}
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        if (failure)
            failure(error);
    }];
}

- (void)fetchAlertsWithSuccess:(void (^)(NSArray *alerts))success failure:(void (^)(NSError *error))failure
{
	NSDictionary *params = @{@"profileId": [[NSUserDefaults standardUserDefaults] valueForKey:@"profileId"]};
	NSString *path = @"/subscription";
	[self postPath:path parameters:params success:^(AFHTTPRequestOperation *op, id response) {
		NSArray *subs = [response valueForKey:@"subscriptions"];
		if (subs) {
			[[NSUserDefaults standardUserDefaults] setObject:subs forKey:@"subscriptions"];
		} else {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"subscriptions"];
		}

        if (success) {
            success(subs);
		}
	} failure:^(AFHTTPRequestOperation *op, NSError *error) {
		if (failure) {
		   failure(error);
		}
	}];
}

@end
