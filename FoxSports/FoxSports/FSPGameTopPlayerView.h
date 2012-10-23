//
//  FSPGameTopPlayerView.h
//  FoxSports
//
//  Created by Matthew Fay on 4/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * This enum is to specify which side you want the player photo on
 */
typedef enum {
    FSPGamePlayerDirectionLeft = 0,
    FSPGamePlayerDirectionRight
} FSPGamePlayerDirection;

@class FSPTeamPlayer;

@interface FSPGameTopPlayerView : UIView

- (id)initWithDirection:(FSPGamePlayerDirection)direction;


/**
 * Updates subviews with appropriate values from player and team.
 * statType refers to the string value for the player's stat type, e.g., 'pts', or 'Ast'.
 * statValue refers to the value for the player's stat type, e.g., '13' of '13 points' or '8' of '8 assists'.
 * title refers to the label that can specify what the player is shown for, e.g. 'Top Points'
 */
- (void)populateWithPlayer:(FSPTeamPlayer *)player statType:(NSString *)statType statValue:(NSNumber *)statValue title:(NSString *)title;

@end
