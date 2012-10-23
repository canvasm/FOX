//
//  FSPSoccerPlayer.m
//  FoxSports
//
//  Created by Matthew Fay on 7/9/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerPlayer.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPSoccerPlayer

@dynamic minutesPlayed;
@dynamic shots;
@dynamic shotsOnGoal;
@dynamic foulsCommitted;
@dynamic foulsSuffered;
@dynamic goalsAllowed;
@dynamic shotsAgainst;
@dynamic shotsOnGoalAgainst;

@dynamic assists;
@dynamic goals;
@dynamic subbedIn;
@dynamic subbedOut;
@dynamic cards;

- (void)updateStatsFromDictionary:(NSDictionary *)stats withContext:(NSManagedObjectContext *)context
{
    NSNumber * noValue = @0;
    
    //Field Player Stats
    self.minutesPlayed = [stats fsp_objectForKey:@"MP" defaultValue:noValue];
    self.shots = [stats fsp_objectForKey:@"S" defaultValue:noValue];
    self.shotsOnGoal = [stats fsp_objectForKey:@"SG" defaultValue:noValue];
    self.foulsCommitted = [stats fsp_objectForKey:@"FC" defaultValue:noValue];
    self.foulsSuffered = [stats fsp_objectForKey:@"FS" defaultValue:noValue];
    
    //Goalie Stats
    self.goalsAllowed = [stats fsp_objectForKey:@"GA" defaultValue:noValue];
    self.shotsAgainst = [stats fsp_objectForKey:@"SH" defaultValue:noValue];
    self.shotsOnGoalAgainst = [stats fsp_objectForKey:@"GSH" defaultValue:noValue];
}

@end
