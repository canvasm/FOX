//
//  FSPNascarPlayerStandingsView.h
//  FoxSports
//
//  Created by Stephen Spring on 7/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPRacingSeasonStats;

@interface FSPNASCARPlayerStandingsView : UIView

/*!
 @abstract Populates the view with stats.
 @param stats The driver's stats
 */
- (void)populateWithStats:(FSPRacingSeasonStats *)stats;

@end
