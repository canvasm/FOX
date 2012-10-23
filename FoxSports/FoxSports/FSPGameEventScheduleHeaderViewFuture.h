//
//  FSPGameEventScheduleHeaderView.h
//  FoxSports
//
//  Created by Laura Savino on 2/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPGameEventScheduleHeaderViewFuture : UIView

/**
 * This label displays the heading "TIME" in addition to the user's local time
 * zone.
 */
@property (nonatomic, strong, readonly) UILabel *timeLabel;

@end
