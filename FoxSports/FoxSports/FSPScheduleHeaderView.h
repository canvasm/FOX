//
//  FSPScheduleHeaderView.h
//  FoxSports
//
//  Created by greay on 4/24/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPScheduleGame.h"

extern CGFloat const FSPLeagueScheduleHeaderHeight;

@class FSPStandingsScheduleSectionHeader;
@interface FSPScheduleHeaderView : UIView

@property (nonatomic, retain, readonly) IBOutlet UILabel *columnOneLabel;
@property (nonatomic, retain, readonly) IBOutlet UILabel *columnTwoLabel;
@property (nonatomic, retain, readonly) IBOutlet UILabel *columnThreeLabel;

/**
 * The dark bar at the top of each section..
 */
@property (nonatomic, strong, readonly) FSPStandingsScheduleSectionHeader *topBarView;
@property (nonatomic, strong, readonly) NSArray *labels;

@property (nonatomic, getter = isFuture, assign) BOOL future;
@property (nonatomic, strong) FSPScheduleEvent *event;

/**
 * Formats a date to EEE M/d/yy
 */
+ (NSDateFormatter *) scheduleHeaderViewDateFormatter;

+ (CGFloat)headerHeght;

// Converts the season type from the data string e.g. REGULAR_SEASON to "Regular Season"
- (NSString *)formattedSeasonType;

@end
