//
//  FSPGolfStats.m
//  FoxSports
//
//  Created by greay on 8/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGolfStats.h"
#import "FSPGolfer.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPGolfStats

@dynamic playerName;
@dynamic playerID;
@dynamic points;
@dynamic earnings;
@dynamic scoringAverage;
@dynamic worldRanking;
@dynamic worldRankingPoints;
@dynamic symbolUrl;
@dynamic branch;
@dynamic relationship;


- (void)populateWithDictionary:(NSDictionary *)seasonStats;
{
	/*
	 labelCode = USD;
	 stat = PE;
	 value = 4957158;

	 stat = TP;
	 value = "2269.24";

	 stat = SA;
	 value = "70.1";

	 stat = WR;
	 value = 1;

	 stat = WRP;
	 value = "141.8";
	 */
	
	// self.playerName = [seasonStats fsp_objectForKey:@"SN" defaultValue:@"--"];
	// self.playerID = ...
	self.earnings = [seasonStats fsp_objectForKey:@"PE" defaultValue:@-1];
	self.points = [seasonStats fsp_objectForKey:@"TP" defaultValue:@-1.0];
	self.scoringAverage = [seasonStats fsp_objectForKey:@"SA" defaultValue:@-1.0];
	self.worldRanking = [seasonStats fsp_objectForKey:@"WR" defaultValue:@-1];
	self.worldRankingPoints = [seasonStats fsp_objectForKey:@"WRP" defaultValue:@-1.0];
}

- (void)populateWithStandingsArray:(NSArray *)stats
{
	for (NSDictionary *stat in stats) {
		NSString *key = [stat valueForKey:@"stat"];
		NSNumber *value = @([[stat fsp_objectForKey:@"value" expectedClass:NSNumber.class] floatValue]);
		if ([key isEqualToString:@"PE"]) {
			self.earnings = value;
		} else if ([key isEqualToString:@"TP"]) {
			self.points = value;
		} else if ([key isEqualToString:@"SA"]) {
			self.scoringAverage = value;
		} else if ([key isEqualToString:@"WR"]) {
			self.worldRanking = value;
		} else if ([key isEqualToString:@"WRP"]) {
			self.worldRankingPoints = value;
		}
	}
}

- (NSString *)earningsString
{
    static NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    });
    NSString *formattedWinnings = [formatter stringFromNumber:self.earnings];
    NSArray *formattedWinningsComponents = [formattedWinnings componentsSeparatedByString:@"."];
    return [formattedWinningsComponents objectAtIndex:0];
}

- (NSString *)pointsString
{
    static NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
		formatter.usesGroupingSeparator = YES;
		formatter.groupingSeparator = @",";
		formatter.groupingSize = 3;
    });
    NSString *formattedPoints = [formatter stringFromNumber:self.points];
	return formattedPoints;
}

@end
