//
//  FSPHockeyPeriodStats.h
//  FoxSports
//
//  Created by Matthew Fay on 8/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPHockeyGame;

@interface FSPHockeyPeriodStats : NSManagedObject

@property (nonatomic, retain) NSNumber * period;
@property (nonatomic, retain) NSNumber * shotsOnGoal;
@property (nonatomic, retain) FSPHockeyGame *homeGame;
@property (nonatomic, retain) FSPHockeyGame *awayGame;

@end
