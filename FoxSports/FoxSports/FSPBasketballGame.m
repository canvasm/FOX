//
//  FSPBasketballGame.m
//  FoxSports
//
//  Created by Jason Whitford on 3/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPBasketballGame.h"
#import "NSDictionary+FSPExtensions.h"
#import "FSPTeam.h"

@implementation FSPBasketballGame

@dynamic highPointsLosing;
@dynamic highPointsLosingPlayerName;
@dynamic highPointsWinning;
@dynamic highPointsWinningPlayerName;
@dynamic highRebounds;
@dynamic highReboundsPlayerName;

- (NSUInteger)maxTimeouts
{
    if ([self.branch isEqualToString:FSPNBAEventBranchType])
        return 7;
    else if ([self.branch isEqualToString:FSPNCAABasketballEventBranchType] || [self.branch isEqualToString:FSPNCAAWBasketballEventBranchType])
        return 6;
    else
        return 0;
}

- (void)populateWithDictionary:(NSDictionary *)eventData;
{
    [super populateWithDictionary:eventData];

    NSArray *stats = [eventData fsp_objectForKey:@"stats" expectedClass:NSArray.class];
    NSString *homePlayerName;
    NSString *homePlayerPoints;
    NSString *awayPlayerName;
    NSString *awayPlayerPoints;
    for (NSDictionary *playerStat in stats) {
        if ([[playerStat objectForKey:@"stat"] isEqualToString:@"PTS"]) {
            if ([[playerStat objectForKey:@"team"] isEqualToString:@"h"]) {
                homePlayerName = [playerStat fsp_objectForKey:@"name" defaultValue:@""];
                homePlayerPoints = [playerStat fsp_objectForKey:@"value" defaultValue:@""];
            } else {
                awayPlayerName = [playerStat fsp_objectForKey:@"name" defaultValue:@""];
                awayPlayerPoints = [playerStat fsp_objectForKey:@"value" defaultValue:@""];
            }
        }
    }

    if ([self.homeTeamIdentifier isEqualToString:self.winningTeamIdentifier]) {
        self.highPointsWinningPlayerName = homePlayerName;
        self.highPointsWinning = homePlayerPoints;
        self.highPointsLosingPlayerName = awayPlayerName;
        self.highPointsLosing = awayPlayerPoints;
    } else if ([self.awayTeamIdentifier isEqualToString:self.winningTeamIdentifier]) {
        self.highPointsWinningPlayerName = awayPlayerName;
        self.highPointsWinning = awayPlayerPoints;
        self.highPointsLosingPlayerName = homePlayerName;
        self.highPointsLosing = homePlayerPoints;
    }
    
    //TODO: see if this is needed
    self.highReboundsPlayerName = [eventData fsp_objectForKey:@"highReboundsPlayerName" defaultValue:@""];
    self.highRebounds = [eventData fsp_objectForKey:@"highRebounds" defaultValue:@""];
}

- (BOOL)matchupAvailable
{
    if (self.homeTeam.pointsPerGame || self.awayTeam.pointsPerGame) return YES;
    else return NO;
}

- (BOOL)isOvertime
{
    if (self.segmentNumber.intValue > 4) return YES;
    else return NO;
}

- (NSUInteger)numberOfOvertimes
{
    return self.segmentNumber.intValue - 4;
}

@end
