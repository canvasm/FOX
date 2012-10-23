//
//  FSPTennisSeasonStats.m
//  FoxSports
//
//  Created by Matthew Fay on 8/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPTennisSeasonStats.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPTennisSeasonStats

@dynamic rank;
@dynamic points;
@dynamic earnings;
@dynamic branch;
@dynamic playerID;
@dynamic playerName;
@dynamic flagURL;
@dynamic player;


- (void)populateWithDictionary:(NSDictionary *)seasonStats;
{
    NSLog(@"%@",seasonStats);
}

- (void)populateWithStandingsArray:(NSArray *)stats
{
	for (NSDictionary *stat in stats) {
		NSString *key = [stat valueForKey:@"stat"];
		NSNumber *value = @([[stat fsp_objectForKey:@"value" expectedClass:NSNumber.class] integerValue]);
		if ([key isEqualToString:@"WRP"]) {
			self.points = value;
		} else if ([key isEqualToString:@"WR"]) {
			self.rank = value;
		} else if ([key isEqualToString:@"PE"]) {
			self.earnings = value;
		}
	}
}

@end
