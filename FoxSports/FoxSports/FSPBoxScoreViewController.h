//
//  FSPBoxScoreViewController.h
//  FoxSports
//
//  Created by Laura Savino on 5/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPEventDetailSectionManaging.h"

@class FSPGame, FSPFootballGame;

@interface FSPBoxScoreViewController : UIViewController <FSPEventDetailSectionManaging>

@property (nonatomic, strong) FSPGame *currentGame;

- (id)initWithGame:(FSPGame *)game;

/**
 * Changes visible stats & header between home & away teams.
 */
- (void)swapVisibleTeam:(id)sender;

/**
 * Reloads all table view data.
 */
- (void)reloadTableViews;

/**
 * Returns size including max height of tallest table view (between home and away).
 *
 * If one table view is shorter than the other, it will have space at the bottom.
 */
- (CGSize)sizeForContents;

@end
