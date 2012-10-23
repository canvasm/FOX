//
//  FSPFootballPlayer.m
//  FoxSports
//
//  Created by Matthew Fay on 7/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPFootballPlayer.h"
#import "NSDictionary+FSPExtensions.h"

@implementation FSPFootballPlayer

@dynamic foxPointsDefense;
@dynamic foxPointsKicking;
@dynamic foxPointsPassing;
@dynamic foxPointsReceiving;
@dynamic foxPointsRushing;
@dynamic foxPointsTotal;
@dynamic defensiveForcedFumbles;
@dynamic fumblesLost;
@dynamic fumblesRecovered;
@dynamic fieldGoalAttempts;
@dynamic fieldGoalLongestLength;
@dynamic fieldGoalsMade;
@dynamic fieldGoalPercentage;
@dynamic defensiveInterceptions;
@dynamic defensiveInterceptionTouchdowns;
@dynamic defensiveInterceptionYards;
@dynamic kickReturns;
@dynamic kickReturnAverage;
@dynamic kickReturnLongest;
@dynamic kickReturnTouchdowns;
@dynamic kickReturnYards;
@dynamic passingAttempts;
@dynamic passingAverage;
@dynamic passingCompletions;
@dynamic passingInterceptions;
@dynamic passingTouchdowns;
@dynamic passingYards;
@dynamic defendedPasses;
@dynamic puntInside20;
@dynamic puntAverageLength;
@dynamic puntLongestLength;
@dynamic puntNumber;
@dynamic puntReturns;
@dynamic puntReturnAverage;
@dynamic puntReturnLongest;
@dynamic puntReturnTouchdowns;
@dynamic puntReturnYards;
@dynamic receptions;
@dynamic receptionAverage;
@dynamic receptionLongestLength;
@dynamic receptionTouchdowns;
@dynamic receptionYards;
@dynamic rusingAttempts;
@dynamic rushingAverage;
@dynamic rushingLongestLength;
@dynamic rushingTouchdowns;
@dynamic rushingYards;
@dynamic defensiveSacks;
@dynamic totalTouchdowns;
@dynamic defensiveTackles;
@dynamic kickingExtraPointAttempts;
@dynamic kickingExtraPointsMade;
@dynamic quarterbackRating;
@dynamic assistedTackles;

- (void)updateStatsFromDictionary:(NSDictionary *)stats withContext:(NSManagedObjectContext *)context
{
    self.foxPointsDefense = [stats fsp_objectForKey:@"FPD" defaultValue:@0];
    self.foxPointsKicking = [stats fsp_objectForKey:@"FPK" defaultValue:@0];
    self.foxPointsPassing = [stats fsp_objectForKey:@"FPP" defaultValue:@0];
    self.foxPointsReceiving = [stats fsp_objectForKey:@"FPRE" defaultValue:@0];
    self.foxPointsRushing = [stats fsp_objectForKey:@"FPRU" defaultValue:@0];
    self.foxPointsTotal = [stats fsp_objectForKey:@"FPT" defaultValue:@0];
    self.defensiveForcedFumbles = [stats fsp_objectForKey:@"FBF" defaultValue:@0];
    self.fumblesLost = [stats fsp_objectForKey:@"FBL" defaultValue:@0];
    self.fumblesRecovered = [stats fsp_objectForKey:@"FBR" defaultValue:@0];
    self.fieldGoalAttempts = [stats fsp_objectForKey:@"FGA" defaultValue:@0];
    self.fieldGoalLongestLength = [stats fsp_objectForKey:@"FGLG" defaultValue:@0];
    self.fieldGoalsMade = [stats fsp_objectForKey:@"FGM" defaultValue:@0];
    self.fieldGoalPercentage = [stats fsp_objectForKey:@"FGP" defaultValue:@0];
    self.defensiveInterceptions = [stats fsp_objectForKey:@"INT" defaultValue:@0];
    self.defensiveInterceptionTouchdowns = [stats fsp_objectForKey:@"INTTD" defaultValue:@0];
    self.defensiveInterceptionYards = [stats fsp_objectForKey:@"IY" defaultValue:@0];
    self.kickReturns = [stats fsp_objectForKey:@"KR" defaultValue:@0];
    self.kickReturnAverage = [stats fsp_objectForKey:@"KRAV" defaultValue:@0];
    self.kickReturnLongest = [stats fsp_objectForKey:@"KRLG" defaultValue:@0];
    self.kickReturnTouchdowns = [stats fsp_objectForKey:@"KRTD" defaultValue:@0];
    self.kickReturnYards = [stats fsp_objectForKey:@"KRY" defaultValue:@0];
    self.passingAttempts = [stats fsp_objectForKey:@"PAA" defaultValue:@0];
    self.passingAverage = [stats fsp_objectForKey:@"PAAV" defaultValue:@0];
    self.passingCompletions = [stats fsp_objectForKey:@"PAC" defaultValue:@0];
    self.passingInterceptions = [stats fsp_objectForKey:@"PAI" defaultValue:@0];
    self.passingTouchdowns = [stats fsp_objectForKey:@"PATD" defaultValue:@0];
    self.passingYards = [stats fsp_objectForKey:@"PAY" defaultValue:@0];
    self.defendedPasses = [stats fsp_objectForKey:@"PD" defaultValue:@0];
    self.puntInside20 = [stats fsp_objectForKey:@"PU20" defaultValue:@0];
    self.puntAverageLength = [stats fsp_objectForKey:@"PUAVL" defaultValue:@0];
    self.puntLongestLength = [stats fsp_objectForKey:@"PULG" defaultValue:@0];
    self.puntNumber = [stats fsp_objectForKey:@"PUN" defaultValue:@0];
    self.puntReturns = [stats fsp_objectForKey:@"PUR" defaultValue:@0];
    self.puntReturnAverage = [stats fsp_objectForKey:@"PURAVG" defaultValue:@0];
    self.puntReturnLongest = [stats fsp_objectForKey:@"PURLG" defaultValue:@0];
    self.puntReturnTouchdowns = [stats fsp_objectForKey:@"PURTD" defaultValue:@0];
    self.puntReturnYards = [stats fsp_objectForKey:@"PURY" defaultValue:@0];
    self.receptions = [stats fsp_objectForKey:@"REC" defaultValue:@0];
    self.receptionAverage = [stats fsp_objectForKey:@"REAV" defaultValue:@0];
    self.receptionLongestLength = [stats fsp_objectForKey:@"RELG" defaultValue:@0];
    self.receptionTouchdowns = [stats fsp_objectForKey:@"RETD" defaultValue:@0];
    self.receptionYards = [stats fsp_objectForKey:@"REY" defaultValue:@0];
    self.rusingAttempts = [stats fsp_objectForKey:@"RUA" defaultValue:@0];
    self.rushingAverage = [stats fsp_objectForKey:@"RUAV" defaultValue:@0];
    self.rushingLongestLength = [stats fsp_objectForKey:@"RULG" defaultValue:@0];
    self.rushingTouchdowns = [stats fsp_objectForKey:@"RUTD" defaultValue:@0];
    self.rushingYards = [stats fsp_objectForKey:@"RUY" defaultValue:@0];
    self.defensiveSacks = [stats fsp_objectForKey:@"SCK" defaultValue:@0];
    self.totalTouchdowns = [stats fsp_objectForKey:@"TD" defaultValue:@0];
    self.defensiveTackles = [stats fsp_objectForKey:@"TKL" defaultValue:@0];
    self.kickingExtraPointAttempts = [stats fsp_objectForKey:@"XPA" defaultValue:@0];
    self.kickingExtraPointsMade = [stats fsp_objectForKey:@"XPM" defaultValue:@0];
    self.quarterbackRating = [stats fsp_objectForKey:@"QBR" defaultValue:@0.0f];
	self.assistedTackles = [stats fsp_objectForKey:@"AST" defaultValue:@0];
}

@end
