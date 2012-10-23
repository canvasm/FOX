//
//  FSPRacingSeasonStats.m
//  FoxSports
//
//  Created by Matthew Fay on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPRacingSeasonStats.h"
#import "FSPRacingPlayer.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPRacingSeasonStats

@dynamic playerID;
@dynamic behind;
@dynamic lapsLed;
@dynamic name;
@dynamic points;
@dynamic poles;
@dynamic rank;
@dynamic starts;
@dynamic top5;
@dynamic top10;
@dynamic wins;
@dynamic winnings;
@dynamic racers;
@dynamic branch;
@dynamic racerName;
@dynamic carNumber;

- (void)populateWithDictionary:(NSDictionary *)seasonStats;
{
    NSNumber *noValue = @-1;
    self.name = [seasonStats fsp_objectForKey:@"SN" defaultValue:@"--"];
    self.rank = [seasonStats fsp_objectForKey:@"R" defaultValue:noValue];
    self.points = [seasonStats fsp_objectForKey:@"PT" defaultValue:noValue];
    self.behind = [seasonStats fsp_objectForKey:@"B" defaultValue:noValue];
    self.starts = [seasonStats fsp_objectForKey:@"S" defaultValue:noValue];
    self.poles = [seasonStats fsp_objectForKey:@"PL" defaultValue:noValue];
    self.wins = [seasonStats fsp_objectForKey:@"W" defaultValue:noValue];
    self.top5 = [seasonStats fsp_objectForKey:@"T5" defaultValue:noValue];
    self.top10 = [seasonStats fsp_objectForKey:@"T10" defaultValue:noValue];
    self.lapsLed = [seasonStats fsp_objectForKey:@"LL" defaultValue:noValue];
    self.winnings = @([[seasonStats fsp_objectForKey:@"WIN" defaultValue:noValue] intValue]);
}

- (void)populateWithStandingsArray:(NSArray *)stats
{
	for (NSDictionary *stat in stats) {
		NSString *key = [stat valueForKey:@"stat"];
		NSNumber *value = @([[stat fsp_objectForKey:@"value" expectedClass:NSNumber.class] integerValue]);
		if ([key isEqualToString:@"TP"]) {
			self.points = value;
		} else if ([key isEqualToString:@"POL"]) {
			self.poles = value;
		} else if ([key isEqualToString:@"TW"]) {
			self.wins = value;
		} else if ([key isEqualToString:@"T5W"]) {
			self.top5 = value;
		} else if ([key isEqualToString:@"T10W"]) {
			self.top10 = value;
		} else if ([key isEqualToString:@"PE"]) {
			self.winnings = value;
		} else if ([key isEqualToString:@"carNumber"]) {
			self.carNumber = value;
		}
	}
}

- (NSString *)winningsInCurrencyFormat
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    numberFormatter.generatesDecimalNumbers = NO;
    NSString *winnings = [numberFormatter stringFromNumber:self.winnings];
    NSArray *winningsComponents = [winnings componentsSeparatedByString:@"."];
    return [winningsComponents objectAtIndex:0];
}

@end
