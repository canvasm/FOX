//
//  FSPScheduleEvent.h
//  FoxSports
//
//  Created by Matthew Fay on 6/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSPScheduleEvent : NSObject
@property (nonatomic, strong) NSString * branch;

@property (nonatomic, strong) NSString * uniqueIdentifier;

/**
 The events start date.
 */
@property (nonatomic, strong) NSDate * startDate;

/**
 The events end date.
 */
@property (nonatomic, strong) NSDate * endDate;

/**
 The start date of this event with the timestamp normalized to 00:00:00.
 */
@property (nonatomic, strong) NSDate *normalizedStartDate;

/**
 The network that this event will be displayed on.
 */
@property (nonatomic, strong) NSString * channelDisplayName;

/**
 For displaying the start time.
 */
@property (nonatomic, strong) NSString *displayStartTime;

/**
 Pre-season or regular season
 */
@property (nonatomic, strong) NSString *seasonType;

/**
 The Name of the event's last winner
 */
@property (nonatomic, strong) NSString *name;

/**
 The name of the stat.
 */
@property (nonatomic, strong) NSString *stat;

/**
 An array of FSPChannel objects.
 */
@property (nonatomic, strong) NSArray *channels;

/**
 Returns the date passed in formatted for display in style DD dd/MM.
 */
+ (NSString *)dateFormattedForDisplayInSectionHeader:(NSDate *)date;

- (NSString *)formattedCurrency:(NSString *)prize;

- (void)populateWithDictionary:(NSDictionary *)dictionary;

@end
