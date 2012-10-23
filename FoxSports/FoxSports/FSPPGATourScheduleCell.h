//
//  FSPPGATourScheduleCell.h
//  FoxSports
//
//  Created by Matthew Fay on 3/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPScheduleCell.h"

extern NSString * const FSPPGATourScheduleCellIdentifier;

@class FSPPGAEvent;

@interface FSPPGATourScheduleCell : FSPScheduleCell

- (void)populateWithEvent:(FSPPGAEvent *)event;

/*!
 @abstract Figures out the approproate cell height determined by the index passed in.
 @param index The index of the 
 @return The height the cell needs to be for the schedule event passed in.
 */
+ (CGFloat)cellHeightForSheduleEvent:(FSPScheduleEvent *)scheduleEvent;

@end
