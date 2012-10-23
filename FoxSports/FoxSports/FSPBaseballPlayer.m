//
//  FSPBaseballPlayer.m
//  FoxSports
//
//  Created by Matthew Fay on 6/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPBaseballPlayer.h"
#import "FSPBaseballGame.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPBaseballPlayer

//pitching stats (season)
@dynamic losses;
@dynamic seasonERA;
@dynamic seasonWHIP;
@dynamic wins;
@dynamic saves;

//pitching stats (game)
@dynamic inningsPitched;
@dynamic hitsAgainst;
@dynamic runsAllowed;
@dynamic earnedRuns;
@dynamic pitchCount;
@dynamic homeRuns;
@dynamic ballsThrown;
@dynamic strikesThrown;
@dynamic walksThrown;
@dynamic strikeOutsThrown;

//hitting stats (game)
@dynamic atBats;
@dynamic runs;
@dynamic hits;
@dynamic runsBattedIn;
@dynamic stolenBases;
@dynamic battingAverage;
@dynamic walks;
@dynamic strikeOuts;
@dynamic battingOrder;

@dynamic subBatting;
@dynamic subPitching;

//associated game
@dynamic awayBaseballGame;
@dynamic homeBaseballGame;

- (void)updateStatsFromDictionary:(NSDictionary *)stats withContext:(NSManagedObjectContext *)context
{
    NSNumber * noValue = @0;
    
    //pitcher stats
    if ([stats objectForKey:@"PC"]) {
        self.inningsPitched = [stats fsp_objectForKey:@"IP" defaultValue:noValue];
        self.hitsAgainst = [stats fsp_objectForKey:@"HA" defaultValue:noValue];
        self.runsAllowed = [stats fsp_objectForKey:@"RA" defaultValue:noValue];
        self.earnedRuns = [stats fsp_objectForKey:@"ER" defaultValue:noValue];
        self.seasonERA = [stats fsp_objectForKey:@"ERA" defaultValue:noValue];
        self.walksThrown = [stats fsp_objectForKey:@"BBG" defaultValue:noValue];
        self.strikeOutsThrown = [stats fsp_objectForKey:@"KG" defaultValue:noValue];
        self.pitchCount = [stats fsp_objectForKey:@"PC" defaultValue:noValue];
        self.homeRuns = [stats fsp_objectForKey:@"HR" defaultValue:noValue];
        self.ballsThrown = [stats fsp_objectForKey:@"BT" defaultValue:noValue];
        self.strikesThrown = [stats fsp_objectForKey:@"ST" defaultValue:noValue];
        self.wins = [stats fsp_objectForKey:@"W" defaultValue:noValue];
        self.losses = [stats fsp_objectForKey:@"L" defaultValue:noValue];
        self.saves = [stats fsp_objectForKey:@"SV" defaultValue:noValue];
    } else {
        self.atBats = [stats fsp_objectForKey:@"AB" defaultValue:noValue];
        self.runs = [stats fsp_objectForKey:@"R" defaultValue:noValue];
        self.hits = [stats fsp_objectForKey:@"H" defaultValue:noValue];
        self.runsBattedIn = [stats fsp_objectForKey:@"RBI" defaultValue:noValue];
        self.stolenBases = [stats fsp_objectForKey:@"SB" defaultValue:noValue];
        self.battingAverage = [stats fsp_objectForKey:@"AVG" defaultValue:@0.0f];
        self.walks = [stats fsp_objectForKey:@"BB" defaultValue:noValue];
        self.strikeOuts = [stats fsp_objectForKey:@"K" defaultValue:noValue];
    }
    
}

- (NSString *)seasonERAString {
	return [NSString stringWithFormat:@"%.2f", [self.seasonERA floatValue]];
}

- (NSString *)seasonWHIPString {
	return [NSString stringWithFormat:@"%.2f", [self.seasonWHIP floatValue]];
}


@end
