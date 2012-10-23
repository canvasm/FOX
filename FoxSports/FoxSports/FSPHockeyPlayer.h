//
//  FSPHockeyPlayer.h
//  FoxSports
//
//  Created by Ryan McPherson on 8/3/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPTeamPlayer.h"


@interface FSPHockeyPlayer : FSPTeamPlayer

@property (nonatomic, retain) NSNumber * goalsScored;
@property (nonatomic, retain) NSNumber * assists;
@property (nonatomic, retain) NSNumber * plusMinus;
@property (nonatomic, retain) NSNumber * shotsOnGoal;
@property (nonatomic, retain) NSNumber * hits;
@property (nonatomic, retain) NSNumber * blockedShots;
@property (nonatomic, retain) NSNumber * penaltyMinutes;
@property (nonatomic, retain) NSNumber * shifts;
@property (nonatomic, retain) NSNumber * timeOnIceMins;
@property (nonatomic, retain) NSNumber * timeOnIceSecs;
@property (nonatomic, retain) NSNumber * totalShotsOnGoal;
@property (nonatomic, retain) NSNumber * goalsAllowed;
@property (nonatomic, retain) NSNumber * saves;
@property (nonatomic, retain) NSNumber * savePercentage;
@property (nonatomic, retain) NSNumber * star;

- (NSString *)timeOnIce;

@end
