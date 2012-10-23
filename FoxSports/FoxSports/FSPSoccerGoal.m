//
//  FSPSoccerGoal.m
//  FoxSports
//
//  Created by Matthew Fay on 7/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerGoal.h"
#import "FSPSoccerGame.h"
#import "FSPSoccerPlayer.h"
#import "FSPTeam.h"
#import "NSDictionary+FSPExtensions.h"

static const int FSPOwnGoal = 3;


@implementation FSPSoccerGoal

@dynamic minute;
@dynamic sequenceNumber;
@dynamic goalType;
@dynamic fieldArea;
@dynamic goalScorer;
@dynamic assistPlayer;
@dynamic homeGame;
@dynamic awayGame;
@dynamic soccerTeam;

- (void)populateWithDictionary:(NSDictionary *)dictionary;
{
    NSDictionary *time = [dictionary fsp_objectForKey:@"TIME" defaultValue:NSDictionary.new];
    self.minute = [time fsp_objectForKey:@"M" defaultValue:[NSNumber numberWithInt:-1]];
    if ([[time fsp_objectForKey:@"P" defaultValue:[NSNumber numberWithInt:-1]] isEqualToNumber:[NSNumber numberWithInt:1]] && self.minute.intValue >= 45)
        self.minute = [NSNumber numberWithInt:45];
    else
        self.minute = [NSNumber numberWithInt:self.minute.intValue + 1];
    
    NSNumber *noValue = [NSNumber numberWithInt:-1];
    NSSet *players;
    NSNumber *goalId = [dictionary fsp_objectForKey:@"PID" defaultValue:noValue];
    NSNumber *assistId = [dictionary fsp_objectForKey:@"APID" defaultValue:noValue];
    
    self.fieldArea = [dictionary fsp_objectForKey:@"FA" defaultValue:@"--"];
    self.goalType = [dictionary fsp_objectForKey:@"PT" defaultValue:noValue];
    
    if (self.homeGame) {
        self.soccerTeam = self.homeGame.homeTeam;
        if ([self.goalType isEqualToNumber:[NSNumber numberWithInt:FSPOwnGoal]])
            players = self.homeGame.awayTeamPlayers;
        else
            players = self.homeGame.homeTeamPlayers;
        
    } else if (self.awayGame) {
        self.soccerTeam = self.awayGame.awayTeam;
        if ([self.goalType isEqualToNumber:[NSNumber numberWithInt:FSPOwnGoal]])
            players = self.awayGame.homeTeamPlayers;
        else
            players = self.awayGame.awayTeamPlayers;
        
    }
    
    for (FSPSoccerPlayer *player in players) {
        if ([player.liveEngineID isEqualToNumber:goalId])
            self.goalScorer = player;
        if ([player.liveEngineID isEqualToNumber:assistId])
            self.assistPlayer = player;
    }
}

@end
