//
//  FSPTeamPlayer.h
//  FoxSports
//
//  Created by Chase Latta on 4/9/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSPPlayer.h"

@class FSPGame;

@interface FSPTeamPlayer : FSPPlayer

@property (nonatomic, retain) NSNumber * starter;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSNumber * sub;
@property (nonatomic, retain) FSPGame *homeGame;
@property (nonatomic, retain) FSPGame *awayGame;

@end
