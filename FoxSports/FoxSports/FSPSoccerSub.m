//
//  FSPSoccerSub.m
//  FoxSports
//
//  Created by Matthew Fay on 7/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerSub.h"
#import "FSPSoccerPlayer.h"
#import "FSPTeam.h"
#import "FSPSoccerGame.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPSoccerSub

@dynamic sequenceNumber;
@dynamic minute;
@dynamic soccerTeam;
@dynamic inPlayer;
@dynamic outPlayer;
@dynamic homeGame;
@dynamic awayGame;

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
    NSNumber *inPlayerId = [dictionary fsp_objectForKey:@"IPID" defaultValue:noValue];
    NSNumber *outPlayerId = [dictionary fsp_objectForKey:@"OPID" defaultValue:noValue];
    if (self.homeGame) {
        self.soccerTeam = self.homeGame.homeTeam;
        players = self.homeGame.homeTeamPlayers;
    } else if (self.awayGame) {
        self.soccerTeam = self.awayGame.awayTeam;
        players = self.awayGame.awayTeamPlayers;
    }
    
    for (FSPSoccerPlayer *player in players) {
        if ([player.liveEngineID isEqualToNumber:inPlayerId])
            self.inPlayer = player;
        if ([player.liveEngineID isEqualToNumber:outPlayerId])
            self.outPlayer = player;
    }
}

@end
