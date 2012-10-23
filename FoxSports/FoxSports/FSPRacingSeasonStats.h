//
//  FSPRacingSeasonStats.h
//  FoxSports
//
//  Created by Matthew Fay on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPRacingPlayer;

@interface FSPRacingSeasonStats : NSManagedObject

@property (nonatomic, retain) NSNumber * behind;
@property (nonatomic, retain) NSNumber * lapsLed;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSNumber * poles;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSNumber * starts;
@property (nonatomic, retain) NSNumber * top5;
@property (nonatomic, retain) NSNumber * top10;
@property (nonatomic, retain) NSNumber * wins;
@property (nonatomic, retain) NSNumber * winnings;
@property (nonatomic, retain) NSSet *racers;
@property (nonatomic, retain) NSString * playerID;
@property (nonatomic, retain) NSString * branch;
@property (nonatomic, retain) NSString * racerName;
@property (nonatomic, retain) NSNumber * carNumber;

- (void)populateWithDictionary:(NSDictionary *)seasonStats;
- (void)populateWithStandingsArray:(NSArray *)stats;
- (NSString *)winningsInCurrencyFormat;

@end
