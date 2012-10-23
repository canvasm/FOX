//
//  FSPScheduleCell.h
//  FoxSports
//
//  Created by greay on 4/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const FSPTimeLabelX;
extern CGFloat const FSPTVLabelX;
extern CGFloat const FSPChannelLabelX;

@class FSPScheduleGame;
@class FSPScheduleEvent;

@interface FSPScheduleCell : UITableViewCell

@property (nonatomic, weak, readonly) UILabel *col0Label;
@property (nonatomic, weak, readonly) UILabel *col1Label;
@property (nonatomic, weak, readonly) UILabel *col2Label;
@property (nonatomic, weak, readonly) UILabel *col3Label;

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *valueLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *lightLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *darkLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *orangeLabels;

/**
 * Whether the cell is displaying a future game.
 */
@property (nonatomic, getter = isFuture, assign) BOOL future;

/**
 * This is to populate the League schedule cell depending on the game.
 * This will automatically show a future or past cell depending on the start date of the game.
 */
- (void)populateWithGame:(FSPScheduleGame *)game;

/**
 * Similar to the above, but populates the cell with a non-team event.
 */
- (void)populateWithEvent:(FSPScheduleEvent *)event;

/**
 * Lays out subviews based on whether the cell is displaying a future game;
 * exposed so subclasses may call it as needed.
 */
- (void)updateSubviewPositions;

/**
 * Convenience method for formatting the game start date in h:mma
 * exposed for subclasses
 */
- (NSString *)startDateStringFromEvent:(FSPScheduleEvent *)event;

+ (CGFloat) heightForEvent:(FSPScheduleEvent *)game;

@end
