//
//  FSPBaseballGame.h
//  FoxSports
//
//  Created by Chase Latta on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPGame.h"

@class FSPBaseballPlayer;

@interface FSPBaseballGame : FSPGame

@property (nonatomic, retain) NSNumber * outs;
@property (nonatomic, retain) NSNumber * baseRunners;

@property (nonatomic, retain) NSString * winningPlayer;
@property (nonatomic, retain) NSString * losingPlayer;
@property (nonatomic, retain) NSString * savingPlayer;

@property (nonatomic, retain) NSNumber * awayHits;
@property (nonatomic, retain) NSNumber * awayErrors;
@property (nonatomic, retain) NSNumber * homeHits;
@property (nonatomic, retain) NSNumber * homeErrors;

@property (nonatomic, retain) FSPBaseballPlayer * homeTeamStartingPitcher;
@property (nonatomic, retain) FSPBaseballPlayer * awayTeamStartingPitcher;

@property (nonatomic, retain) NSNumber * homeWinningPitcherID;
@property (nonatomic, retain) NSNumber * homeLosingPitcherID;
@property (nonatomic, retain) NSNumber * homeSavingPitcherID;
@property (nonatomic, retain) NSNumber * awayWinningPitcherID;
@property (nonatomic, retain) NSNumber * awayLosingPitcherID;
@property (nonatomic, retain) NSNumber * awaySavingPitcherID;


@end
