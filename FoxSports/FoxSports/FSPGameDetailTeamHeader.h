//
//  FSPGameDetailTeamHeader.h
//  FoxSports
//
//  Created by Matthew Fay on 3/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPTeam;

@interface FSPGameDetailTeamHeader : UIView

/**
 * Exposed so that containing classes can set custom fonts on this label.
 */
@property (nonatomic, weak, readonly) UILabel *teamNameLabel;

/**
 * Setting this property updates the UI with the team name & color.
 */
@property (readonly, weak) FSPTeam *team;
- (void)setTeam:(FSPTeam *)team teamColor:(UIColor *)teamColor;


/**
 * Update the header with the given team's abbreviated name and color.
 */
- (void)setTeamWithShortNameDisplay:(FSPTeam *)team teamColor:(UIColor *)teamColor;

@end
