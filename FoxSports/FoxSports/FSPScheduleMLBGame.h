//
//  FSPScheduleMLBGame.h
//  FoxSports
//
//  Created by Matthew Fay on 6/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleGame.h"

@interface FSPScheduleMLBGame : FSPScheduleGame
@property (nonatomic, strong) NSString *winningPlayer;
@property (nonatomic, strong) NSString *losingPlayer;
@property (nonatomic, strong) NSString *savingPlayer;
@end
