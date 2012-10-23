//
//  FSPScheduleGame.m
//  FoxSports
//
//  Created by greay on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleGame.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPOrganization.h"

@implementation FSPScheduleGame

@synthesize homeTeamName;
@synthesize awayTeamName;
@synthesize homeTeamAbbreviation;
@synthesize awayTeamAbbreviation;
@synthesize homeTeamScore;
@synthesize awayTeamScore;
@synthesize homeTeam;
@synthesize awayTeam;

- (void)populateWithDictionary:(NSDictionary *)dictionary
{
	[super populateWithDictionary:dictionary];
        
	self.homeTeamScore = [dictionary fsp_objectForKey:@"homeTeamScore" defaultValue:@"--"];
    self.awayTeamScore = [dictionary fsp_objectForKey:@"visitingTeamScore" defaultValue:@"--"];
}

@end
