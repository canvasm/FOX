//
//  FSPCarRacingEvent.m
//  FoxSports
//
//  Created by Laura Savino on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPRacingEvent.h"
#import "FSPCoreDataManager.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPRacingEvent

@dynamic eventTitle;
@dynamic venueName;
@dynamic raceType;
@dynamic length;
@dynamic trackType;
@dynamic location;
@dynamic totalLaps;
@dynamic racers;
@dynamic trackPhotoURL;
@dynamic trackRecords;

- (void)populateWithDictionary:(NSDictionary *)eventData
{
    [super populateWithDictionary:eventData];
    
    self.eventTitle = [eventData fsp_objectForKey:@"eventTitle" defaultValue:@""];
    self.raceType = [eventData fsp_objectForKey:@"raceType" defaultValue:@""];
    self.venueName = [eventData fsp_objectForKey:@"venueName" defaultValue:@""];
}

- (void)populateSegmentInformationWithDictionary:(NSDictionary *)segmentData
{
    self.totalLaps = [segmentData fsp_objectForKey:@"TL" defaultValue:@0];
}

- (void)populateWithPreRaceDictionary:(NSDictionary *)preRace;
{
    [self.managedObjectContext performBlock:^{
        NSDictionary * trackData = [preRace fsp_objectForKey:@"track" expectedClass:NSDictionary.class];
        NSArray * recordsData = [preRace fsp_objectForKey:@"records" expectedClass:NSArray.class];
        
        if (trackData) {
            self.length = [trackData fsp_objectForKey:@"length" defaultValue:@"--"];
            self.trackType = [trackData fsp_objectForKey:@"type" defaultValue:@"--"];
            self.location = [trackData fsp_objectForKey:@"location" defaultValue:@"--"];
            self.trackPhotoURL = [trackData fsp_objectForKey:@"imageUrl" expectedClass:NSString.class];
        }
        
        if (recordsData) {
            FSPRacingTrackRecords *trackRecord;
            NSMutableSet * records = [NSMutableSet set];
            
            NSArray *values = [self.trackRecords allObjects];
            NSArray *keys = [values valueForKeyPath:@"recordName"];
            NSDictionary *existingRecords = [NSDictionary dictionaryWithObjects:values forKeys:keys];
            
            for (NSDictionary * record in recordsData) {
                trackRecord = [existingRecords objectForKey:[record objectForKey:@"name"]];
                if (!trackRecord)
                    trackRecord = [NSEntityDescription insertNewObjectForEntityForName:@"FSPRacingTrackRecords" inManagedObjectContext:self.managedObjectContext];
                
                [trackRecord populateWithDictionary:record];
                [records addObject:trackRecord];
            }
            self.trackRecords = [NSSet setWithSet:records];
        }
    }];
}

#pragma mark FSPTournamentEvent protocol methods

- (NSString *)tournamentTitle
{
    return self.eventTitle;
}

- (NSString *)tournamentSubtitle
{
    return self.raceType;
}

- (NSString *)location
{
    return self.venueName;
}
@end
