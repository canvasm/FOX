//
//  FSPGameOdds.h
//  FoxSports
//
//  Created by Chase Latta on 3/21/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPGame;

@interface FSPGameOdds : NSManagedObject

@property (nonatomic, retain) NSString * homeTeamMoneyLine;
@property (nonatomic, retain) NSString * homeTeamPointSpread;
@property (nonatomic, retain) NSString * homeTeamPSMoneyLine;
@property (nonatomic, retain) NSString * awayTeamMoneyLine;
@property (nonatomic, retain) NSString * awayTeamPointSpread;
@property (nonatomic, retain) NSString * awayTeamPSMoneyLine;
@property (nonatomic, retain) FSPGame *game;

@end
