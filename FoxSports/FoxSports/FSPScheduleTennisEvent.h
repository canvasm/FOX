//
//  FSPScheduleTennisEvent.h
//  FoxSports
//
//  Created by Matthew Fay on 8/28/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPScheduleEvent.h"

@interface FSPScheduleTennisEvent : FSPScheduleEvent
/**
 The event's end date.
 */
@property (nonatomic, strong) NSDate * endDate;

/**
 The event's title.
 */
@property (nonatomic, strong) NSString * eventTitle;

/**
 The event's location.
 */
@property (nonatomic, strong) NSString * location;

/**
 The event's surface.
 */
@property (nonatomic, strong) NSString * surface;

/**
 The event's winning player name.
 */
@property (nonatomic, strong) NSString * winnerName;

/**
 The event's prize money won.
 */
@property (nonatomic, strong) NSString * winningPrize;
@end
