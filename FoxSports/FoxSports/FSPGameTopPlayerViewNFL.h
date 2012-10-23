//
//  FSPGameTopPlayerViewNFL.h
//  FoxSports
//
//  Created by Stephen Spring on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameTopPlayerView.h"

@interface FSPGameTopPlayerViewNFL : FSPGameTopPlayerView

/*!
 @abstract Updates subview with appropriate values from player
 @param player The player who's stats are to be shown
 @param statTypes An array of NSString objects that are the stat names. No more than 4 objects.
 @param statValues An array of NSNumber objects that are the values for the corresponding statTypes. No more than 4 objects.
 */
- (void)populateWithPlayer:(FSPTeamPlayer *)player statTypes:(NSArray *)statTypes statValues:(NSArray *)statValues;

@end
