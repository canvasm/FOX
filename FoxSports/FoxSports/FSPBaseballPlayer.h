//
//  FSPBaseballPlayer.h
//  FoxSports
//
//  Created by Matthew Fay on 6/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPTeamPlayer.h"

@class FSPBaseballGame;

@interface FSPBaseballPlayer : FSPTeamPlayer

//pitching stats (season)
@property (nonatomic, retain) NSNumber * losses;
@property (nonatomic, retain) NSNumber * seasonERA;
@property (nonatomic, retain) NSNumber * seasonWHIP;
@property (nonatomic, retain) NSNumber * wins;
@property (nonatomic, retain) NSNumber * saves;

- (NSString *)seasonERAString;
- (NSString *)seasonWHIPString;

//pitching stats (game)
@property (nonatomic, retain) NSNumber * inningsPitched;
@property (nonatomic, retain) NSNumber * hitsAgainst;
@property (nonatomic, retain) NSNumber * runsAllowed;
@property (nonatomic, retain) NSNumber * earnedRuns;
@property (nonatomic, retain) NSNumber * pitchCount;
@property (nonatomic, retain) NSNumber * homeRuns;
@property (nonatomic, retain) NSNumber * ballsThrown;
@property (nonatomic, retain) NSNumber * strikesThrown;
@property (nonatomic, retain) NSNumber * walksThrown;
@property (nonatomic, retain) NSNumber * strikeOutsThrown;

//hitting stats (game)
@property (nonatomic, retain) NSNumber * atBats;
@property (nonatomic, retain) NSNumber * runs;
@property (nonatomic, retain) NSNumber * hits;
@property (nonatomic, retain) NSNumber * runsBattedIn;
@property (nonatomic, retain) NSNumber * stolenBases;
@property (nonatomic, retain) NSNumber * battingAverage;
@property (nonatomic, retain) NSNumber * walks;
@property (nonatomic, retain) NSNumber * strikeOuts;
@property (nonatomic, retain) NSNumber * battingOrder;

@property (nonatomic, retain) NSNumber * subBatting;
@property (nonatomic, retain) NSNumber * subPitching;

//associated game
@property (nonatomic, retain) FSPBaseballGame *awayBaseballGame;
@property (nonatomic, retain) FSPBaseballGame *homeBaseballGame;

@end
