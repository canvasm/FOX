//
//  FSPPGAGolferDetailView.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPGolfer;

@interface FSPPGAGolferDetailView : UIView

/*!
 @abstract Populates the view with data from the golfer.
 @param golfer The golfer to populate the view with.
 */
- (void)populateWithGolfer:(FSPGolfer *)golfer;

/*!
 @abstract Returns the rounds of the golfer passed in sorted in order.
 @param golfer The golfer who's rounds are to be sorted.
 */
+ (NSArray *)sortedGolferRounds:(FSPGolfer *)golfer;

@end
