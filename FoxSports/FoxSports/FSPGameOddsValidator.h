//
//  FSPGameOddsValidator.h
//  FoxSports
//
//  Created by Laura Savino on 4/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPObjectValidator.h"

@class FSPGame;

@interface FSPGameOddsValidator : FSPObjectValidator

/**
 * Ensures that the array of odds corresponds with the teams in the game; if yes, returns
 * the array; else, returns nil
 */
- (NSArray *)validOddsArray: (NSArray *)oddsArray forGame:(FSPGame *)game;

@end
