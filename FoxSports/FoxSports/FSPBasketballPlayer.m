//
//  FSPBasketballPlayer.m
//  FoxSports
//
//  Created by Jason Whitford on 3/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPBasketballPlayer.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPBasketballPlayer

@dynamic assists;
@dynamic blocks;
@dynamic defensiveRebounds;
@dynamic disqualifications;
@dynamic ejections;
@dynamic fieldGoalPercentage;
@dynamic fieldGoalsAttempted;
@dynamic fieldGoalsMade;
@dynamic flagrantFouls;
@dynamic freeThrowPercentage;
@dynamic freeThrowsAttempted;
@dynamic freeThrowsMade;
@dynamic games;
@dynamic gamesStarted;
@dynamic minutesPlayed;
@dynamic offensiveRebounds;
@dynamic personalFouls;
@dynamic plusMinus;
@dynamic points;
@dynamic rebounds;
@dynamic secondsPlayed;
@dynamic steals;
@dynamic technicalFouls;
@dynamic threePointPercentage;
@dynamic threePointsAttempted;
@dynamic threePointsMade;
@dynamic turnovers;

//TODO: use strings table?
//TODO: uncomment percentages when fixed in the feed (if needed in app)
- (void)updateStatsFromDictionary:(NSDictionary *)stats withContext:(NSManagedObjectContext *)context
{
//    NSNumber *zeroFloat = [NSNumber numberWithFloat:0.0f];
    NSNumber *zeroInt = @0;
    self.assists = [stats fsp_objectForKey:@"AST" defaultValue:zeroInt];
    self.blocks = [stats fsp_objectForKey:@"BLK" defaultValue:zeroInt];
    self.defensiveRebounds = [stats fsp_objectForKey:@"DREB" defaultValue:zeroInt];
    self.disqualifications = [stats fsp_objectForKey:@"D" defaultValue:zeroInt];
    self.ejections = [stats fsp_objectForKey:@"E" defaultValue:zeroInt];
//    self.fieldGoalPercentage = [stats fsp_objectForKey:@"FGP" defaultValue:zeroInt];
    self.fieldGoalsAttempted = [stats fsp_objectForKey:@"FGA" defaultValue:zeroInt];
    self.fieldGoalsMade = [stats fsp_objectForKey:@"FGM" defaultValue:zeroInt];
    self.flagrantFouls = [stats fsp_objectForKey:@"FF" defaultValue:zeroInt];
//    self.freeThrowPercentage = [stats fsp_objectForKey:@"FTP" defaultValue:zeroFloat];
    self.freeThrowsAttempted = [stats fsp_objectForKey:@"FTA" defaultValue:zeroInt];
    self.freeThrowsMade = [stats fsp_objectForKey:@"FTM" defaultValue:zeroInt];
    self.games = [stats fsp_objectForKey:@"G" defaultValue:zeroInt];
    self.gamesStarted = [stats fsp_objectForKey:@"GS" defaultValue:zeroInt];
    self.minutesPlayed = [stats fsp_objectForKey:@"M" defaultValue:zeroInt];
    self.offensiveRebounds = [stats fsp_objectForKey:@"OREB" defaultValue:zeroInt];
    self.personalFouls = [stats fsp_objectForKey:@"PF" defaultValue:zeroInt];
    self.plusMinus = [stats fsp_objectForKey:@"PM" defaultValue:zeroInt];
    self.points = [stats fsp_objectForKey:@"PTS" defaultValue:zeroInt];
    self.rebounds = [stats fsp_objectForKey:@"REB" defaultValue:zeroInt];
    self.secondsPlayed = [stats fsp_objectForKey:@"S" defaultValue:zeroInt];
    self.steals = [stats fsp_objectForKey:@"STL" defaultValue:zeroInt];
    self.technicalFouls = [stats fsp_objectForKey:@"TF" defaultValue:zeroInt];
//    self.threePointPercentage = [stats fsp_objectForKey:@"TPP" defaultValue:zeroFloat];
    self.threePointsAttempted = [stats fsp_objectForKey:@"TPA" defaultValue:zeroInt];
    self.threePointsMade = [stats fsp_objectForKey:@"TPM" defaultValue:zeroInt];
    self.turnovers = [stats fsp_objectForKey:@"T" defaultValue:zeroInt];
}

@end
