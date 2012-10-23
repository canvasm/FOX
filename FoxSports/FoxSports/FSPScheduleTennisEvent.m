//
//  FSPScheduleTennisEvent.m
//  FoxSports
//
//  Created by Matthew Fay on 8/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleTennisEvent.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPScheduleTennisEvent
@synthesize endDate;
@synthesize eventTitle;
@synthesize location;
@synthesize surface;
@synthesize winnerName;
@synthesize winningPrize;

- (void)populateWithDictionary:(NSDictionary *)dictionary;
{
    [super populateWithDictionary:dictionary];

    NSNumber *end = [dictionary fsp_objectForKey:@"endDate" defaultValue:@0];
    self.endDate = [NSDate dateWithTimeIntervalSince1970:end.doubleValue];
    
    self.eventTitle = [dictionary fsp_objectForKey:@"eventTitle" defaultValue:@"--"];
    self.location = [dictionary fsp_objectForKey:@"locationName" defaultValue:@"--"];
    self.seasonType = [dictionary fsp_objectForKey:@"season" defaultValue:@"--"];
    
    NSArray *stats = [dictionary fsp_objectForKey:@"stats" defaultValue:NSArray.new];
    for (NSDictionary * stat in stats) {
        NSString *value = [stat objectForKey:@"stat"];
        if ([value isEqualToString:@"SUR"])
            self.surface = [stat fsp_objectForKey:@"value" defaultValue:@"--"];
        else if ([value isEqualToString:@"WIN"]) {
            self.winnerName = [stat fsp_objectForKey:@"name" defaultValue:@"--"];
            self.winningPrize = [self formattedCurrency:[stat fsp_objectForKey:@"value" defaultValue:@"--"]];
        }
    }
}
@end
