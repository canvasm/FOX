//
//  FSPEventChipHeader.h
//  FoxSports
//
//  Created by Chase Latta on 1/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPEvent, FSPLabel;

@interface FSPEventChipHeader : UIView

/**
 * A collection of labels whose shadows toggle between the same colors on cell
 * selection
 */
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *labelsToToggleOnSelection;

@property (nonatomic, weak, readonly) FSPLabel *nowPlayingLabel;

/**
 * Describes whether the game has completed or is in progress; in the case of
 * upcoming games, shows the date and time of the game.
 */
@property (nonatomic, weak, readonly) FSPLabel *gameStateLabel;
@property (nonatomic, weak, readonly) FSPLabel *networkLabel;

@property (nonatomic, getter = isStreamable, readonly) BOOL streamable;
@property (nonatomic, getter = isInProgress, readonly) BOOL inProgress;

/**
 * Whether the game is in 'final' status.
 */
@property (nonatomic, assign, getter = isCompleted) BOOL completed;

/**
 * Populates the header's subviews with details about the event.
 */
- (void)populateWithEvent:(FSPEvent *)event;

/**
 * Configures the view for selected/unselected state as part of a table view
 */
@property (nonatomic) BOOL selected;

@end
