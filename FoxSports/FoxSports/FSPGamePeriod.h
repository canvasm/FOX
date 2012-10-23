//
//  FSPGamePeriod.h
//  FoxSports
//
//  Created by Laura Savino on 2/4/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPGame;

@interface FSPGamePeriod : NSManagedObject

@property (nonatomic, retain) NSNumber * homeTeamScore;
@property (nonatomic, retain) NSNumber * awayTeamScore;
@property (nonatomic, retain) NSNumber * period;
@property (nonatomic, retain) FSPGame *game;

@end
