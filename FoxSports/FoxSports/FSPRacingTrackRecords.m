//
//  FSPRacingTrackRecords.m
//  FoxSports
//
//  Created by Matthew Fay on 7/17/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPRacingTrackRecords.h"
#import "FSPRacingEvent.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPRacingTrackRecords

@dynamic recordAchievedDate;
@dynamic recordName;
@dynamic recordHolder;
@dynamic recordValue;
@dynamic track;

- (void)populateWithDictionary:(NSDictionary *)record;
{
    self.recordAchievedDate = [record fsp_objectForKey:@"date" defaultValue:@"--"];
    self.recordName = [record fsp_objectForKey:@"name" defaultValue:@"--"];
    // temp workaround for data issue where holder date returns an array or dictionary
    if ([[record fsp_objectForKey:@"holder" defaultValue:@"--"] isKindOfClass:[NSString class]]) {
        self.recordHolder = [record fsp_objectForKey:@"holder" defaultValue:@"--"];
    } else {
        self.recordHolder = nil;
    }
    self.recordValue = [record fsp_objectForKey:@"value" defaultValue:@"--"];
}

@end
