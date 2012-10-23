//
//  FSPTennisSeasonStats.h
//  FoxSports
//
//  Created by Matthew Fay on 8/29/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPTennisPlayer;

@interface FSPTennisSeasonStats : NSManagedObject

@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSNumber * earnings;
@property (nonatomic, retain) NSString * branch;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSString * playerName;
@property (nonatomic, retain) NSString * flagURL;
@property (nonatomic, retain) FSPTennisPlayer *player;

- (void)populateWithDictionary:(NSDictionary *)seasonStats;
- (void)populateWithStandingsArray:(NSArray *)stats;

@end
