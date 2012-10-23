//
//  FSPPGAEvent.m
//  FoxSports
//
//  Created by Laura Savino on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGAEvent.h"
#import "NSDictionary+FSPExtensions.h"
#import "NSDate+FSPExtensions.h"

@implementation FSPPGAEvent

@dynamic eventTitle;
@dynamic locationName;
@dynamic venueName;
@dynamic winnerName;
@dynamic winnerPrizeMoney;
@dynamic winnerScore;
@dynamic winnerStrokesUnder;
@dynamic golfers;

- (void)populateWithDictionary:(NSDictionary *)eventData;
{
    [super populateWithDictionary:eventData];

    self.eventTitle = [eventData fsp_objectForKey:@"eventTitle" defaultValue:@""];
    self.venueName = [eventData fsp_objectForKey:@"venueName" defaultValue:@""];
    self.locationName = [eventData fsp_objectForKey:@"locationName" defaultValue:@""];
    self.winnerName = [eventData fsp_objectForKey:@"winnerName" defaultValue:@""];
    self.winnerPrizeMoney = [eventData fsp_objectForKey:@"winnerPrizeMoney" expectedClass:NSNumber.class];
    self.winnerScore = [eventData fsp_objectForKey:@"winnerScore" expectedClass:NSNumber.class];
    self.winnerStrokesUnder = [eventData fsp_objectForKey:@"winnerStrokesUnder" expectedClass:NSNumber.class];
}

- (void)populateSegmentInformationWithDictionary:(NSDictionary *)segmentData;
{
    self.segmentNumber = [segmentData fsp_objectForKey:@"RD" defaultValue:@"-1"];
    self.segmentDescription = @"Round";
    self.eventState = [self eventStateFromInteger:[segmentData fsp_objectForKey:@"ST" defaultValue:@-1]];
}

- (NSString *)eventStateFromInteger:(NSNumber *)status
{
    NSString * statusString;
    
    switch (status.integerValue) {
        case 1:
            statusString = @"Pre-Tourney";
            break;
        case 2:
            statusString = @"In-Progress";
            break;
        case 4:
            statusString = @"Final";
            break;
        case 5:
            statusString = @"Postponed";
            break;
        case 6:
            statusString = @"Suspended";
            break;
        case 7:
            statusString = @"Delayed";
            break;
            
        default:
            break;
    }
    return statusString;
}

#pragma mark FSPTournamentEvent protocol methods

- (NSString *)tournamentTitle
{
    return self.eventTitle;
}

- (NSString *)tournamentSubtitle
{
    return [NSString stringWithFormat:@"%@, %@", self.venueName, self.locationName];
}

- (NSString *)location
{
    return self.locationName;
}

- (NSString *)dateGroup
{
    BOOL isFuture = NO;
    if ([self.startDate fsp_isToday]){
        isFuture = YES;
    } else {
        NSComparisonResult comparisonResult = [(NSDate *)[NSDate date] compare:self.startDate];
        isFuture = (comparisonResult == NSOrderedAscending);
    }
    if (isFuture)
        return @"Future";
    return @"Past";
}


@end
