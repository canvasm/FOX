//
//  FSPUFCEvent.m
//  FoxSports
//
//  Created by Laura Savino on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCEvent.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPUFCMassRelevanceViewController.h"

@implementation FSPUFCEvent

@dynamic eventSubtitle;
@dynamic eventTitle;
@dynamic locationName;
@dynamic fights;

- (void)populateWithDictionary:(NSDictionary *)eventData
{    
    [super populateWithDictionary:eventData];
    
    self.eventSubtitle = [eventData fsp_objectForKey:@"eventSubtitle" defaultValue:@""];
    self.eventTitle = [eventData fsp_objectForKey:@"eventTitle" defaultValue:@""];
    self.locationName = [eventData fsp_objectForKey:@"locationName" defaultValue:@""];
}

#pragma mark FSPTournamentEvent protocol methods

- (NSString *)tournamentTitle
{
    return self.eventTitle;
}

- (NSString *)tournamentSubtitle
{
    return self.eventSubtitle;
}

- (NSString *)location
{
    return self.locationName;
}

- (Class)getMassRelevanceClass
{
    return [FSPUFCMassRelevanceViewController class];
}

@end
