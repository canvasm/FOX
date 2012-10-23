//
//  FSPGamePeriod.m
//  FoxSports
//
//  Created by Laura Savino on 2/4/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGamePeriod.h"
#import "FSPGame.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPGamePeriod

@dynamic homeTeamScore;
@dynamic awayTeamScore;
@dynamic period;
@dynamic game;


- (NSString *)description;
{
    return [NSString stringWithFormat:@"period %d: %d to %d", self.period.intValue, self.homeTeamScore.intValue, self.awayTeamScore.intValue];
}


@end
