//
//  FSPUFCPlayer.h
//  FoxSports
//
//  Created by Matthew Fay on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPPlayer.h"

@class FSPUFCFight;

@interface FSPUFCPlayer : FSPPlayer

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * draws;
@property (nonatomic, retain) NSString * fightsOutOf;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * homeTown;
@property (nonatomic, retain) NSNumber * losses;
@property (nonatomic, retain) NSNumber * reach;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSNumber * wins;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSNumber * isBeltHolder;

@property (nonatomic, retain) NSNumber * strikesAbsorbedPerMinute;
@property (nonatomic, retain) NSNumber * strikesLandedPerMinute;
@property (nonatomic, retain) NSNumber * strikingAccuracy;
@property (nonatomic, retain) NSNumber * strikingDefense;
@property (nonatomic, retain) NSNumber * submissionAverage;
@property (nonatomic, retain) NSNumber * takedownAccuracy;
@property (nonatomic, retain) NSNumber * takedownAverage;
@property (nonatomic, retain) NSNumber * takedownDefense;

@property (nonatomic, retain) FSPUFCFight *fightAsFighter1;
@property (nonatomic, retain) FSPUFCFight *fightAsFighter2;

- (NSString *)getFormattedStats;

@end
