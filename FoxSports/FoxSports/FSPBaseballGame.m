//
//  FSPBaseballGame.m
//  FoxSports
//
//  Created by Chase Latta on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPBaseballGame.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPBaseballGame

@dynamic outs;
@dynamic baseRunners;
@dynamic winningPlayer, losingPlayer, savingPlayer;
@dynamic homeTeamStartingPitcher;
@dynamic awayTeamStartingPitcher;
@dynamic awayHits;
@dynamic awayErrors;
@dynamic homeHits;
@dynamic homeErrors;
@dynamic homeWinningPitcherID;
@dynamic homeLosingPitcherID;
@dynamic homeSavingPitcherID;
@dynamic awayWinningPitcherID;
@dynamic awayLosingPitcherID;
@dynamic awaySavingPitcherID;

- (NSString *)lastNameFromFullName:(NSString *)fullName {
	NSRange r = [fullName rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
	if (r.location != NSNotFound) {
		return [fullName substringFromIndex:r.location + 1];
	} else {
		return fullName;
	}
}

- (void)populateWithDictionary:(NSDictionary *)eventData;
{
    [super populateWithDictionary:eventData];
	NSArray *stats = [eventData fsp_objectForKey:@"stats" expectedClass:NSArray.class];
    for (NSDictionary *playerStat in stats) {
        if ([[playerStat objectForKey:@"stat"] isEqualToString:@"WP"]) {
			self.winningPlayer = [self lastNameFromFullName:[playerStat fsp_objectForKey:@"name" defaultValue:@""]];
        }
		else if ([[playerStat objectForKey:@"stat"] isEqualToString:@"LP"]) {
			self.losingPlayer = [self lastNameFromFullName:[playerStat fsp_objectForKey:@"name" defaultValue:@""]];
        }
		else if ([[playerStat objectForKey:@"stat"] isEqualToString:@"SVP"]) {
			self.savingPlayer = [self lastNameFromFullName:[playerStat fsp_objectForKey:@"name" defaultValue:@""]];
        }
    }
}

- (void)populateSegmentInformationWithDictionary:(NSDictionary *)segmentData;
{
    //TODO: remove this when feed is updated
    id holder = [segmentData fsp_objectForKey:@"I" defaultValue:@"1"];
    if ([holder isKindOfClass:[NSNumber class]]) {
        self.segmentNumber = ((NSNumber *)holder).stringValue;
    } else if ([holder isKindOfClass:[NSString class]]) {
        self.segmentNumber = holder;
    }else {
        NSLog(@"type %@", holder);
    }
    
    self.segmentDescription = [segmentData fsp_objectForKey:@"TB" defaultValue:@"T"];
    self.outs = [segmentData fsp_objectForKey:@"O" defaultValue:@0];
    
    NSNumber *baseRunners = [segmentData fsp_objectForKey:@"BR" defaultValue:@-1];
    if (baseRunners.intValue == 3)
        baseRunners = @4;
    else if (baseRunners.intValue == 4)
        baseRunners = @3;
    else if ( baseRunners.intValue > 7) 
        baseRunners = @0;
    self.baseRunners = baseRunners;
    
    self.homeHits = [[segmentData objectForKey:@"H"] fsp_objectForKey:@"HIT" defaultValue:@0];
    self.awayHits = [[segmentData objectForKey:@"A"] fsp_objectForKey:@"HIT" defaultValue:@0];
    self.homeErrors = [[segmentData objectForKey:@"H"] fsp_objectForKey:@"ERR" defaultValue:@0];
    self.awayErrors = [[segmentData objectForKey:@"A"] fsp_objectForKey:@"ERR" defaultValue:@0];
}

- (void)populateWithLiveTeamStatsDictionary:(NSDictionary *)eventData;
{
    [super populateWithLiveTeamStatsDictionary:eventData];
    
    NSNumber * teamID = [eventData objectForKey:@"ID"];
    NSNumber * noValue = @0;
    if ([teamID isEqualToNumber:self.homeTeamLiveEngineID]) {
        self.homeWinningPitcherID = [eventData fsp_objectForKey:@"WPID" defaultValue:noValue];
        self.homeLosingPitcherID = [eventData fsp_objectForKey:@"LPID" defaultValue:noValue];
        self.homeSavingPitcherID = [eventData fsp_objectForKey:@"SPID" defaultValue:noValue];
    } else if ([teamID isEqualToNumber:self.awayTeamLiveEngineID]) {
        self.awayWinningPitcherID = [eventData fsp_objectForKey:@"WPID" defaultValue:noValue];
        self.awayLosingPitcherID = [eventData fsp_objectForKey:@"LPID" defaultValue:noValue];
        self.awaySavingPitcherID = [eventData fsp_objectForKey:@"SPID" defaultValue:noValue];
    }
    
}

- (BOOL)matchupAvailable
{
    if (self.homeTeamStartingPitcher && self.awayTeamStartingPitcher) return YES;
    else return NO;
}

- (BOOL)isOvertime
{
    if (self.segmentNumber.intValue > 9) return YES;
    else return NO;
}

- (NSUInteger)numberOfOvertimes
{
    return self.segmentNumber.intValue;
}

@end
