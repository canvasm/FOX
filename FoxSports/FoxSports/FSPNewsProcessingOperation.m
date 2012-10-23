//
//  FSPTopNewsProcessingOperation.m
//  FoxSports
//
//  Created by Chase Latta on 5/8/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNewsProcessingOperation.h"
#import "FSPCoreDataManager.h"
#import "FSPNewsHeadline.h"
#import "FSPOrganization.h"
#import "FSPNewsCity.h"
#import "FSPManagedObjectCache.h"
#import "NSDictionary+FSPExtensions.h"

#define kHeadlinesGroup @"HEADLINES"


@interface FSPNewsProcessingOperation ()

@property (nonatomic, copy) NSArray *newsArray;
@property (nonatomic, strong) NSManagedObjectID *organizationId;
@property (nonatomic, strong) NSManagedObjectID *cityId;
@property (nonatomic, strong) FSPManagedObjectCache *headlineCache;

@end

@implementation FSPNewsProcessingOperation

@synthesize newsArray = _newsArray;
@synthesize organizationId = _organizationId;
@synthesize cityId = _cityId;


- (id)initWithTopNewsHeadlines:(NSArray *)headlines context:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
        self.newsArray = [headlines copy];
        self.organizationId = nil;
        self.cityId = nil;
        self.headlineCache = [FSPManagedObjectCache cacheForEntityName:NSStringFromClass(FSPNewsHeadline.class)
                                                            primaryKey:@"newsId"
                                                             inContext:self.managedObjectContext];
    }
    return self;
}

- (id)initWithNewsHeadlines:(NSArray *)headlines organizationId:(NSManagedObjectID *)orgId
                    context:(NSManagedObjectContext *)context {
    self = [self initWithTopNewsHeadlines:headlines context:context];
    if (self) {
        self.organizationId = orgId;
    }
    return self;
}

- (id)initWithLocalNewsHeadlines:(NSArray *)headlines newsCityId:(NSManagedObjectID *)newsCityId
                         context:(NSManagedObjectContext *)context {
    self = [self initWithTopNewsHeadlines:headlines context:context];
    if (self) {
        self.cityId = newsCityId;
    }
    return self;
}

- (void)removeOldArticlesInContext:(NSManagedObjectContext *)context;
{
    NSDate *today = [NSDate date];
    NSDate *lastWeek  = [today dateByAddingTimeInterval: -1209600.0];
    
    [self.headlineCache.allObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FSPNewsHeadline *headline = obj;
        if ([headline.publishedDate compare:lastWeek] == NSOrderedAscending) {
            [context deleteObject:headline];
        }
    }];
}

- (void)main
{
    if (!self.newsArray || self.isCancelled)
        return;
    
    [self.managedObjectContext performBlockAndWait:^{
        
        // delete articles that are more than 1 week old
        [self removeOldArticlesInContext:self.managedObjectContext];

        for (NSDictionary *newsItem in self.newsArray) {
            // Check to see if this item exists in the database
            NSString *newsID = [newsItem objectForKey:@"newsId"];
            if (newsID) {
                FSPNewsHeadline *headline = [self.headlineCache lookupObjectByIdentifier:newsID];
                if (!headline) {
                    // this is a new headline, create it in the MOC based on the dictionary from the feed
                    headline = [NSEntityDescription insertNewObjectForEntityForName:@"FSPNewsHeadline"
                                                             inManagedObjectContext:self.managedObjectContext];
                }
                
                // Update properties
                headline.newsId = [newsItem fsp_objectForKey:@"newsId" defaultValue:headline.newsId];
                headline.group = [newsItem fsp_objectForKey:@"group" defaultValue:kHeadlinesGroup];
                headline.imageURL = [newsItem fsp_objectForKey:@"imageUrl" defaultValue:@""];
                headline.title = [newsItem fsp_objectForKey:@"title" defaultValue:headline.title];

                // Update the published date
                NSString *publishedString = [newsItem fsp_objectForKey:@"published" defaultValue:@""];
                if (publishedString) {
                    NSInteger publishedInterval = [publishedString integerValue];
                    if (publishedInterval > 0) {
                        headline.publishedDate = [NSDate dateWithTimeIntervalSince1970:publishedInterval];
                    }
                }
                
                // Update the the isTopNews and organization
                if (self.organizationId) {
                    FSPOrganization *organization = (FSPOrganization *)[self.managedObjectContext existingObjectWithID:self.organizationId error:nil];
                    if (organization) {
                        [headline addOrganizationsObject:organization];
                    }
                }
                
                if (self.cityId) {
                    FSPNewsCity *newsCity = (FSPNewsCity *)[self.managedObjectContext existingObjectWithID:self.cityId error:nil];
                    headline.newsCity = newsCity;
                    headline.cityName = newsCity.cityName;
                }

                if (!(self.organizationId || self.cityId)) {
                    headline.isTopNews = @(YES);
                }
            }
            
            [self.managedObjectContext processPendingChanges];
        }
    }];
}

@end
