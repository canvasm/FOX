//
//  FSPNewsCityProcessingOperation.m
//  FoxSports
//
//  Created by Stephen Spring on 7/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPNewsCityProcessingOperation.h"
#import "FSPCoreDataManager.h"
#import "FSPNewsCity.h"
#import "NSDictionary+FSPExtensions.h"

#define kCitiesKey @"cities"
#define kAffiliatesKey @"affiliates"
#define kCityNameKey @"cityName"
#define kAffiliateNameKey @"affiliateName"
#define kCityIdKey @"cityId"
#define kAffiliateIdKey @"affiliateId"
#define kDefaultStringValue @"--"

@interface FSPNewsCityProcessingOperation()

@property (nonatomic, strong) NSDictionary *newsLocations;

@end

@implementation FSPNewsCityProcessingOperation

@synthesize newsLocations = _newsLocations;

- (id)initWithNewsCities:(NSDictionary *)newsLocations context:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
        _newsLocations = [newsLocations copy]; 
    }
    return self;
}

- (void)main
{
    if (!self.newsLocations || self.isCancelled)
        return;

    [self.managedObjectContext performBlockAndWait:^{
                        
        NSFetchRequest *citiesFetch = [NSFetchRequest fetchRequestWithEntityName:@"FSPNewsCity"];
        NSError *error = nil;
        NSArray *storedCities = [self.managedObjectContext executeFetchRequest:citiesFetch error:&error];
        
        if ([storedCities count] > 0) {
            // Update values for existing cities
            [self updateObjectsForLocationType:kCitiesKey storedCities:storedCities];
            [self updateObjectsForLocationType:kAffiliatesKey storedCities:storedCities];
        } else {
            // Save all incoming objects
            [self saveIncomingLocationsForLocationType:kCitiesKey];
            [self saveIncomingLocationsForLocationType:kAffiliatesKey];
        }
        
        // Refetch objects in context and delete any that are not in the incoming feed
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FSPNewsCity"];
        NSError *fetchError = nil;
        NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
        for (FSPNewsCity *city in fetchResults) {
            BOOL cityFound = NO;
            for (NSDictionary *cityFromFeed in [self.newsLocations objectForKey:kCitiesKey]) {
                if ([city.cityName isEqualToString:[cityFromFeed valueForKey:kCityNameKey]]) {
                    cityFound = YES;
                }
            }
            for (NSDictionary *cityFromFeed in [self.newsLocations objectForKey:kAffiliatesKey]) {
                if ([city.cityName isEqualToString:[cityFromFeed valueForKey:kAffiliateNameKey]]) {
                    cityFound = YES;
                }
            }
            if (!cityFound) {
                [self.managedObjectContext deleteObject:city];
            }
        }
    }];
}

- (void)updateObjectsForLocationType:(NSString *)locationType storedCities:(NSArray *)storedCities
{
    NSString *locationName = [locationType isEqualToString:kCitiesKey] ? kCityNameKey : kAffiliateNameKey;
    
    for (NSDictionary *cityFromService in [self.newsLocations objectForKey:locationType]) {
        BOOL cityFound = NO;
        for (FSPNewsCity *storedCity in storedCities) {
            if ([storedCity.cityName isEqualToString:[cityFromService valueForKey:locationName]]) {
                storedCity.cityId = [cityFromService objectForKey:kCityIdKey];
                storedCity.affiliateId = [cityFromService objectForKey:kAffiliateIdKey];
                cityFound = YES;
            }
        }
        // If a city from the feed is not already stored in the database, insert it.
        if (!cityFound) {
            [self storeCity:cityFromService locationName:locationName];
        }
    }
}

- (void)saveIncomingLocationsForLocationType:(NSString *)locationType
{
    NSString *locationName = [locationType isEqualToString:kCitiesKey] ? kCityNameKey : kAffiliateNameKey;
    
    for (NSDictionary *cityFromService in [self.newsLocations objectForKey:locationType]) {
        [self storeCity:cityFromService locationName:locationName];
    }
}

- (void)storeCity:(NSDictionary *)city locationName:(NSString *)locationName
{
    FSPNewsCity *cityToStore = [NSEntityDescription insertNewObjectForEntityForName:@"FSPNewsCity"
                                                             inManagedObjectContext:self.managedObjectContext];
    cityToStore.cityId = [city objectForKey:kCityIdKey];
    cityToStore.cityName = [city fsp_objectForKey:locationName defaultValue:kDefaultStringValue];
    cityToStore.affiliateId = [city objectForKey:kAffiliateIdKey];
}

@end
