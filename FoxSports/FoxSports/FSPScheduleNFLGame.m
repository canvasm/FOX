//
//  FSPScheduleNFLGame.m
//  FoxSports
//
//  Created by Joshua Dubey on 6/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleNFLGame.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPScheduleNFLGame

@synthesize topGamePasserStats = _topGamePasserStats;
@synthesize topGameRusherStats = _topRusherStats;
@synthesize topGameReceiverStats = _topGameReceiverStats;
@synthesize homeTeamPasserStats = _homeTeamPasserStats;
@synthesize homeTeamRusherStats = _homeTeamRusherStats;
@synthesize homeTeamReceiverStats = _homeTeamReceiverStats;
@synthesize awayTeamPasserStats = _awayTeamPasserStats;
@synthesize awayTeamRusherStats = _awayTeamRusherStats;
@synthesize awayTeamReceiverStats = _awayTeamReceiverStats;

@synthesize weekNumber = _weekNumber;
@synthesize showDateLabel = _showDateLabel;

- (NSString *)lastNameFromFullName:(NSString *)fullName {
	NSRange r = [fullName rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
	if (r.location != NSNotFound) {
		return [fullName substringFromIndex:r.location + 1];
	} else {
		return fullName;
	}
}

- (void)populateWithDictionary:(NSDictionary *)dictionary
{
    [super populateWithDictionary:dictionary];
    
    NSString *homeTeamPassYds;
    NSString *homeTeamPassLeader;
    NSString *awayTeamPassYds;
    NSString *awayTeamPassLeader;
    
    NSString *homeTeamRushYds;
    NSString *homeTeamRushLeader;
    NSString *awayTeamRushYds;
    NSString *awayTeamRushLeader;
    
    NSString *homeTeamRecvYds;
    NSString *homeTeamRecvLeader;
    NSString *awayTeamRecvYds;
    NSString *awayTeamRecvLeader;
    
    NSArray * stats = [dictionary objectForKey:@"stats"];
    for (NSDictionary * d in stats) {
        NSString *stat = [d objectForKey:@"stat"];
        if ([stat isEqualToString:@"PASS"]) {
            if ([@"h" isEqualToString:[d fsp_objectForKey:@"team" defaultValue:@""]]) {
                homeTeamPassYds = [d fsp_objectForKey:@"value" defaultValue:@""];
                homeTeamPassLeader = [d fsp_objectForKey:@"name" defaultValue:@""];
                self.homeTeamPasserStats = [NSString stringWithFormat:@"%@ %@",[self lastNameFromFullName:homeTeamPassLeader], homeTeamPassYds];
            }
            if ([@"v" isEqualToString:[d fsp_objectForKey:@"team" defaultValue:@""]]) {
                awayTeamPassYds = [d fsp_objectForKey:@"value" defaultValue:@""];
                awayTeamPassLeader = [d fsp_objectForKey:@"name" defaultValue:@""];
                self.awayTeamPasserStats = [NSString stringWithFormat:@"%@ %@",[self lastNameFromFullName:awayTeamPassLeader], awayTeamPassYds];
            }
        }
        else if ([stat isEqualToString:@"RUSH"]) {
            if ([@"h" isEqualToString:[d fsp_objectForKey:@"team" defaultValue:@""]]) {
                homeTeamRushYds = [d fsp_objectForKey:@"value" defaultValue:@""];
                homeTeamRushLeader = [d fsp_objectForKey:@"name" defaultValue:@""];
                self.homeTeamRusherStats = [NSString stringWithFormat:@"%@ %@",[self lastNameFromFullName:homeTeamRushLeader], homeTeamRushYds];
            }
            if ([@"v" isEqualToString:[d fsp_objectForKey:@"team" defaultValue:@""]]) {
                awayTeamRushYds = [d fsp_objectForKey:@"value" defaultValue:@""];
                awayTeamRushLeader = [d fsp_objectForKey:@"name" defaultValue:@""];
                self.awayTeamRusherStats = [NSString stringWithFormat:@"%@ %@",[self lastNameFromFullName:awayTeamRushLeader], awayTeamRushYds];
            }
        }
        else  if ([stat isEqualToString:@"RECV"]) {
            if ([@"h" isEqualToString:[d fsp_objectForKey:@"team" defaultValue:@""]]) {
                homeTeamRecvYds = [d fsp_objectForKey:@"value" defaultValue:@""];
                homeTeamRecvLeader = [d fsp_objectForKey:@"name" defaultValue:@""];
                self.homeTeamReceiverStats = [NSString stringWithFormat:@"%@ %@",[self lastNameFromFullName:homeTeamRecvLeader], homeTeamRecvYds];
            }
            if ([@"v" isEqualToString:[d fsp_objectForKey:@"team" defaultValue:@""]]) {
                awayTeamRecvYds = [d fsp_objectForKey:@"value" defaultValue:@""];
                awayTeamRecvLeader = [d fsp_objectForKey:@"name" defaultValue:@""];
                self.awayTeamReceiverStats = [NSString stringWithFormat:@"%@ %@",[self lastNameFromFullName:awayTeamRecvLeader], awayTeamRecvYds];
            }
        }
    }
	
    if (!self.homeTeamPasserStats) self.homeTeamPasserStats = @"--";
	if (!self.awayTeamPasserStats) self.awayTeamPasserStats = @"--";
	if (!self.homeTeamRusherStats) self.homeTeamRusherStats = @"--";
	if (!self.awayTeamRusherStats) self.awayTeamRusherStats = @"--";
	if (!self.homeTeamReceiverStats) self.homeTeamReceiverStats = @"--";
	if (!self.awayTeamReceiverStats) self.awayTeamReceiverStats = @"--";
	
	
    if ([awayTeamPassYds intValue] < [homeTeamPassYds intValue]) {
        self.topGamePasserStats = [NSString stringWithFormat:@"%@ %@", self.homeTeamAbbreviation, self.homeTeamPasserStats];
    } else {
        self.topGamePasserStats = [NSString stringWithFormat:@"%@ %@", self.awayTeamAbbreviation, self.awayTeamPasserStats];
    }
    
    if ([awayTeamRushYds intValue] < [homeTeamRushYds intValue]) {
        self.topGameRusherStats = [NSString stringWithFormat:@"%@ %@", self.homeTeamAbbreviation, self.homeTeamRusherStats];
    }
    else {
        self.topGameRusherStats = [NSString stringWithFormat:@"%@ %@", self.awayTeamAbbreviation, self.awayTeamRusherStats];
    }
    
    if ([awayTeamRecvYds intValue] < [homeTeamRecvYds intValue]) {
        self.topGameReceiverStats = [NSString stringWithFormat:@"%@ %@", self.homeTeamAbbreviation, self.homeTeamReceiverStats];
    }
    else {
        self.topGameReceiverStats = [NSString stringWithFormat:@"%@ %@", self.awayTeamAbbreviation, self.awayTeamReceiverStats];
    }
    
}

@end
