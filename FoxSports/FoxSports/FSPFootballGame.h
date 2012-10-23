//
//  FSPFootballGame.h
//  FoxSports
//
//  Created by Chase Latta on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPGame.h"


@interface FSPFootballGame : FSPGame

@property (nonatomic, retain) NSNumber * homeTeamPossession;
@property (nonatomic, retain) NSNumber * fieldPosition;

@property (nonatomic, retain) NSNumber * awayFirstDowns;
@property (nonatomic, retain) NSNumber * awayFourthDownEfficiency;
@property (nonatomic, retain) NSNumber * awayFumblesLost;
@property (nonatomic, retain) NSNumber * awayInterceptionsThrown;
@property (nonatomic, retain) NSNumber * awayThirdDownEfficiency;

@property (nonatomic, retain) NSString * awayTimeOfPossession;
@property (nonatomic, retain) NSNumber * awayTotalPassAttempts;
@property (nonatomic, retain) NSNumber * awayTotalPassCompletions;
@property (nonatomic, retain) NSNumber * awayTotalPassingYards;
@property (nonatomic, retain) NSNumber * awayTotalRushes;
@property (nonatomic, retain) NSNumber * awayTotalRushingYards;
@property (nonatomic, retain) NSNumber * awayTotalYards;
@property (nonatomic, retain) NSString * awayYardsPerPass;
@property (nonatomic, retain) NSString * awayYardsPerRush;

@property (nonatomic, retain) NSNumber * homeFirstDowns;
@property (nonatomic, retain) NSNumber * homeFourthDownEfficiency;
@property (nonatomic, retain) NSNumber * homeFumblesLost;
@property (nonatomic, retain) NSNumber * homeInterceptionsThrown;
@property (nonatomic, retain) NSNumber * homeThirdDownEfficiency;

@property (nonatomic, retain) NSString * homeTimeOfPossession;
@property (nonatomic, retain) NSNumber * homeTotalPassAttempts;
@property (nonatomic, retain) NSNumber * homeTotalPassCompletions;
@property (nonatomic, retain) NSNumber * homeTotalPassingYards;
@property (nonatomic, retain) NSNumber * homeTotalRushes;
@property (nonatomic, retain) NSNumber * homeTotalRushingYards;
@property (nonatomic, retain) NSNumber * homeTotalYards;
@property (nonatomic, retain) NSString * homeYardsPerPass;
@property (nonatomic, retain) NSString * homeYardsPerRush;

@end
