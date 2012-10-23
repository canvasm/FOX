//
//  FSPScheduleNHLGame.m
//  FoxSports
//
//  Created by Matthew Fay on 8/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleNHLGame.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPScheduleNHLGame
@synthesize playerStatsString;
@synthesize segmentNumber;

- (void)populateWithDictionary:(NSDictionary *)dictionary
{
    [super populateWithDictionary:dictionary];
    NSString *statsString;
    NSString *statsStringValue;
    NSString *nameString = @"--";
    NSString *fullString = @"(";
    NSArray *stats = [dictionary fsp_objectForKey:@"stats" defaultValue:NSArray.new];

    for (NSDictionary *stat in stats)
    {
        if ([nameString isEqualToString:@"--"] && ![[stat fsp_objectForKey:@"name" defaultValue:@"--"] isEqualToString:@""])
            nameString = [stat fsp_objectForKey:@"name" defaultValue:@"--"];
        else {
            statsString = [stat fsp_objectForKey:@"stat" defaultValue:@"--"];
            statsStringValue = [stat fsp_objectForKey:@"value" defaultValue:@"--"];
            fullString = [NSString stringWithFormat:@"%@%@ %@, ", fullString, statsStringValue, statsString];
        }
    }
    if (fullString.length > 1)
        fullString = [fullString stringByReplacingCharactersInRange:NSMakeRange(fullString.length - 2, 2) withString:@")"];
    else
        fullString = @"";
    self.playerStatsString = [NSString stringWithFormat:@"%@ %@", nameString, fullString];
    self.segmentNumber = [dictionary fsp_objectForKey:@"segmentNumber" defaultValue:@""];
}

@end
