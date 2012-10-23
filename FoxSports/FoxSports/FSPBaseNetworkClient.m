//
//  FSPBaseNetworkClient.m
//  FoxSports
//
//  Created by Ed McKenzie on 8/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPBaseNetworkClient.h"
#import "FSPCoreDataManager.h"

@implementation FSPBaseNetworkClient

- (id)initWithBaseURL:(NSURL *)url {
    if ((self = [super initWithBaseURL:url])) {
#ifdef DEBUG_init
        NSLog(@" *** initializing %@ with base URL %@", NSStringFromClass(self.class), [url absoluteString]);
#endif
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _managedObjectContext.parentContext = [[FSPCoreDataManager sharedManager] masterContext];
    }
    return self;
}

- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success
         failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [super postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id param) {
        [self.managedObjectContext performBlock:^{
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"%@: error saving context for POST %@", NSStringFromClass(self.class), path);
            }
            
            if (success) {
                success(operation, param);
            }
        }];
    } failure:failure];
}

- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success
        failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [super getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id param) {
        [self.managedObjectContext performBlock:^{
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"%@: error saving context for GET %@", NSStringFromClass(self.class), path);
            }
            
            if (success) {
                success(operation, param);
            }
        }];
    } failure:failure];
}

@end
