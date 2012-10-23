//
//  FSPScheduleRacingEvent.m
//  FoxSports
//
//  Created by greay on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleRacingEvent.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPScheduleRacingEvent
@synthesize eventTitle, venue, winnerName, winnerCar, poleWinnerName, poleWinnerCar;

- (void)populateWithDictionary:(NSDictionary *)dictionary
{
    [super populateWithDictionary:dictionary];
	/*
	{	branch = "NASCAR_SPRINT";
		channel = (
			{	broadcastDate = "<null>";
				callSign = "FOX";
				isDelayed = "0";
			},
		);
		eventState = "FINAL";
		eventTitle = "Budweiser Shootout";
		fsId = "17361bd5-b0e2-426a-a32a-9462a5c43fdb";
		itemType = "EVENT";
		locationName = "Daytona Beach, Florida, United States";
		season = "2012";
		seasonType = "SPRINT_CUP_SERIES";
		startDate = "2012-02-19 01:29:00 +0000";
		stats = (
			{	name = "<null>";
				stat = "W1";
				value = "<null>";
			},
			{	name = "<null>";
				stat = "W2";
				value = "<null>";
			},
		);
		tba = "0";
		venueName = "Daytona International Speedway";
	}
	 */
	
	self.eventTitle = [dictionary fsp_objectForKey:@"eventTitle" defaultValue:@""];
	self.venue = [dictionary fsp_objectForKey:@"venueName" defaultValue:@""];
	
    NSArray *stats = [dictionary objectForKey:@"stats"];
	for (NSDictionary *d in stats) {
        NSString *stat = [d objectForKey:@"stat"];
        if ([stat isEqualToString:@"W1"]) {
            self.winnerName = [d fsp_objectForKey:@"name" defaultValue:@""];
			self.winnerCar = [d fsp_objectForKey:@"value" defaultValue:@""];
        } else if ([stat isEqualToString:@"W2"]) {
            self.poleWinnerName = [d fsp_objectForKey:@"name" defaultValue:@""];
			self.poleWinnerCar = [d fsp_objectForKey:@"value" defaultValue:@""];
        }
    }

}

@end
