//
//  NSDate+FSPExtensions.h
//  FoxSports
//
//  Created by Chase Latta on 1/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (FSPDateCreation)

/**
 * Returns an NSDate object from an ISO 8601 formatted string.  YYYY-MM-DDTHH:MM:SSZ.
 */
+ (id)fsp_dateFromISO8601String:(NSString *)string;

/**
 * Returns an NSString instance in the ISO 8601 format.  YYYY-MM-DDTHH:MM:SSZ.
 */
- (NSString *)fsp_ISO8601FormattedString;

/**
 Converts the date into a date with a timestamp of 00:00:00
 */
- (NSDate *)fsp_normalizedDate;

/**
 * Returns the date in the accessible format Weekday, MonthName #. 
 */
- (NSString *)fsp_accessibleDateString;

/**
 * Return the time with lowercase am/pm
 */
- (NSString *)fsp_lowercaseMeridianTimeString;
 
/**
 * Return the date with lowercase am/pm
 */
- (NSString *)fsp_lowercaseMeridianDateString;

/**
 * Return the date with format Weekday Day/Month, e.g. "Thur 11/20"
 */
- (NSString *)fsp_weekdayMonthSlashDay;

- (NSString *)fsp_lowercaseMeridianTimeStringWithTimezone;

@end


@interface NSDate (DateComparison)

/**
 Tells whether or not the date is today.
 */
- (BOOL)fsp_isToday;

/**
 * Whether the date is yesterday.
 */
- (BOOL)fsp_isYesterday;

/**
 * Whether the date is tomorrow.
 */
- (BOOL)fsp_isTomorrow;

@end
