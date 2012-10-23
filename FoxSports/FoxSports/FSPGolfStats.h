//
//  FSPGolfStats.h
//  FoxSports
//
//  Created by greay on 8/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FSPGolfStats : NSManagedObject

@property (nonatomic, retain) NSString * playerName;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSNumber * earnings;
@property (nonatomic, retain) NSNumber * scoringAverage;
@property (nonatomic, retain) NSNumber * worldRanking;
@property (nonatomic, retain) NSNumber * worldRankingPoints;
@property (nonatomic, retain) NSString * symbolUrl;
@property (nonatomic, retain) NSString * branch;

@property (nonatomic, retain) NSManagedObject *relationship;

- (NSString *)earningsString;
- (NSString *)pointsString;

- (void)populateWithDictionary:(NSDictionary *)seasonStats;
- (void)populateWithStandingsArray:(NSArray *)stats;

@end
