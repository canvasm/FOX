//
//  NSDate+FSPExtensions.m
//  FoxSports
//
//  Created by Chase Latta on 1/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "NSDate+FSPExtensions.h"

static dispatch_queue_t date_creation_queue() 
{
    static dispatch_queue_t fsp_date_creation_queue = NULL;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        fsp_date_creation_queue = dispatch_queue_create("com.foxsports.date-creation", 0);
    });
    
    return fsp_date_creation_queue;
}

static NSDateFormatter *FSPISO8601Fomatter()
{
    static NSDateFormatter *formatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    });
    
    return formatter;
}

@implementation NSDate (FSPDateCreation)

+ (id)fsp_dateFromISO8601String:(NSString *)string;
{
    if(!string) return nil;

    __block NSDate *theDate = nil;
    
    dispatch_sync(date_creation_queue(), ^{
        NSDateFormatter *formatter = FSPISO8601Fomatter();
        // The dates are coming in as eastern time so we are putting this in temporarily until the feed is fixed. TODO.
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
        theDate = [formatter dateFromString:string];
    });

    return theDate;
}

- (NSString *)fsp_ISO8601FormattedString;
{
    __block NSString *theString = nil;
    
    dispatch_sync(date_creation_queue(), ^{
        NSDateFormatter *formatter = FSPISO8601Fomatter();
        formatter.timeZone = [NSTimeZone localTimeZone];
        theString = [FSPISO8601Fomatter() stringFromDate:self];
    });
    
    return theString;
}

- (NSDate *)fsp_normalizedDate;
{
    static NSCalendar *calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    });

    __block NSDate *theDate = nil;
    dispatch_sync(date_creation_queue(), ^{
        NSDateComponents *components = [calendar components:kCFCalendarUnitDay | kCFCalendarUnitMonth | kCFCalendarUnitYear fromDate:self];
        components.hour = 0;
        components.minute = 0;
        components.second = 0;
        theDate = [calendar dateFromComponents:components];
    });
    
    return theDate;
}

- (NSString *)fsp_accessibleDateString;
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"eeee, MMMM d";
    });
    return [dateFormatter stringFromDate:self];
}

- (NSString *)fsp_lowercaseMeridianTimeString;
{
    static NSDateFormatter *timeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"h:mma";
    });
    
    return [[timeFormatter stringFromDate:self] lowercaseString] ?: @"";
}

- (NSString *)fsp_lowercaseMeridianTimeStringWithTimezone;
{
    static NSDateFormatter *timeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"h:mma";
    });
 
    static NSDateFormatter *timeZoneFormatter = nil;
    static dispatch_once_t twiceToken;
    dispatch_once(&twiceToken, ^{
        timeZoneFormatter = [[NSDateFormatter alloc] init];
        timeZoneFormatter.dateFormat = @"zzz";
    });
    
    NSString *time = [NSString stringWithFormat:@"%@ %@", [[timeFormatter stringFromDate:self] lowercaseString], [timeZoneFormatter stringFromDate:self]];
    return  time ?: @"";
}


- (NSString *)fsp_lowercaseMeridianDateString;
{
    static NSDateFormatter *dayFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dayFormatter = [[NSDateFormatter alloc] init];
        dayFormatter.dateFormat = @"E M/d";
    });
    
    NSString *dateString;
    if([self fsp_isToday]) {
        dateString = [self fsp_lowercaseMeridianTimeString];
    } else {
        NSString *dayString = [dayFormatter stringFromDate:self];
        dateString = dayString ? [NSString stringWithFormat:@"%@ %@", dayString, [self fsp_lowercaseMeridianTimeString]] : @"";
    }
    
    return dateString;
}

- (NSString *)fsp_weekdayMonthSlashDay
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEE M/d";
    });
    return [dateFormatter stringFromDate:self];
}

@end


@implementation NSDate (DateComparison)

- (BOOL)fsp_isToday;
{
    static NSCalendar *calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    });
    
    __block BOOL dateIsToday = NO;
    dispatch_sync(date_creation_queue(), ^{
        NSDate *now = [NSDate date];
        NSDateComponents *components = [calendar components:kCFCalendarUnitDay | kCFCalendarUnitMonth | kCFCalendarUnitYear fromDate:self];
        NSInteger day = [components day];
        NSInteger month = [components month];
        NSInteger year = [components year];
        
        components = [calendar components:kCFCalendarUnitDay | kCFCalendarUnitMonth | kCFCalendarUnitYear fromDate:now];
        NSInteger currentDay = [components day];
        NSInteger currentMonth = [components month];
        NSInteger currentYear = [components year];
        
        dateIsToday = ((currentDay == day) && (currentMonth == month) && (currentYear == year));
    });
    
    return dateIsToday;
}

- (BOOL)fsp_isYesterday
{
    NSDate *normalizedSelf = [self fsp_normalizedDate];
    NSTimeInterval twentyFourHours = 60 * 60 * 24;
    NSDate *normalizedYesterday = [[[NSDate date] dateByAddingTimeInterval:-twentyFourHours] fsp_normalizedDate];
    return [normalizedSelf isEqualToDate:normalizedYesterday];
    
}

- (BOOL)fsp_isTomorrow
{
    NSDate *normalizedSelf = [self fsp_normalizedDate];
    NSTimeInterval twentyFourHours = 60 * 60 * 24;
    NSDate *normalizedTomorrow = [[[NSDate date] dateByAddingTimeInterval:twentyFourHours] fsp_normalizedDate];
    return [normalizedSelf isEqualToDate:normalizedTomorrow];
    
}

@end
